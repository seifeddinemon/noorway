import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/aladhan_api_service.dart';
import '../services/adhan_scheduler.dart';
import 'app_strings.dart';

// Enum replacements for the removed adhan package
enum Madhab { shafi, hanafi }

enum Prayer { none, fajr, sunrise, dhuhr, asr, maghrib, isha }

class PrayerTimesProvider extends ChangeNotifier {
  // Current day's specific timings map (e.g., {'Fajr': '05:00', ...})
  Map<String, dynamic>? _todayTimings;

  // Coordinates default to Makkah
  double _latitude = 21.4225;
  double _longitude = 39.8262;

  String _locationName = AppStrings.get('makkah_name', 'ar');
  String get locationName => _locationName;

  // Method maps to Aladhan API integer codes:
  // 3 = Muslim World League (Default)
  // 4 = Umm Al Qura
  // 2 = ISNA (North America)
  // 5 = Egyptian
  // 1 = Karachi
  int _manualMethod = 3;
  Madhab _madhab = Madhab.shafi;
  bool _useAutoMethod = true;

  int get manualMethod => _manualMethod;
  Madhab get madhab => _madhab;
  bool get useAutoMethod => _useAutoMethod;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isDisposed = false;

  String? _error;
  String? get error => _error;

  PrayerTimesProvider() {
    _loadSavedLocation();
    // Use a small delay to ensure providers are ready and UI is starting
    Future.microtask(() => _initLocation('ar')); // Default to 'ar' for init
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('lat');
      final lng = prefs.getDouble('lng');
      final name = prefs.getString('locationName');

      if (lat != null && lng != null && name != null) {
        _latitude = lat;
        _longitude = lng;
        _locationName = name;
      }

      final methodIndex = prefs.getInt('calc_method_index');
      if (methodIndex != null) {
        _manualMethod = methodIndex;
      }
      _useAutoMethod = prefs.getBool('use_auto_method') ?? true;
      _madhab = Madhab.values[prefs.getInt('madhab_index') ?? 0];

      await calculatePrayerTimes();
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    }
  }

  Future<void> _saveLocation(double lat, double lng, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('lat', lat);
      await prefs.setDouble('lng', lng);
      await prefs.setString('locationName', name);
    } catch (e) {
      debugPrint('Error saving location: $e');
    }
  }

  Future<void> _initLocation(String lang) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Basic Availability Check
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _handleLocationFailure(lang, 'Location services disabled');
        return;
      }

      // 2. Permission Check
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _handleLocationFailure(lang, 'Permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _handleLocationFailure(lang, 'Permission denied forever');
        return;
      }

      // 3. Multi-stage Fetch Strategy
      Position? position;

      // Stage A: Try Last Known Position (Instant)
      try {
        position = await Geolocator.getLastKnownPosition();
        if (position != null) {
          _latitude = position.latitude;
          _longitude = position.longitude;
          await calculatePrayerTimes(); // Immediate UI update
        }
      } catch (e) {
        debugPrint('Last known position error: $e');
      }

      // Stage B: Fast Fix (Balanced/Power Optimized)
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (e) {
        debugPrint('Balanced fetch error, trying high accuracy... $e');
      }

      // Stage C: High Accuracy (Deep Fix)
      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 25),
            ),
          );
        } catch (e) {
          _error = 'GPS Timeout: $e';
          debugPrint('High accuracy fetch error: $e');
        }
      }

      if (position != null) {
        _latitude = position.latitude;
        _longitude = position.longitude;
        await _updateLocationName(position, lang);
        await _saveLocation(_latitude, _longitude, _locationName);
        await calculatePrayerTimes();
      } else if (_latitude == 21.4225) {
        // Only fallback to Makkah if we have NO previous coordinates at all
        _handleLocationFailure(lang, 'No fix available');
      }
    } catch (e) {
      _error = 'Unexpected location error: $e';
      _handleLocationFailure(lang, _error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleLocationFailure(String lang, String reason) {
    debugPrint('Location Failure: $reason');
    if (_latitude == 21.4225) {
      _locationName = AppStrings.get('makkah_default', lang);
    }
    calculatePrayerTimes();
  }

  Future<void> _updateLocationName(Position position, String lang) async {
    try {
      final locale = lang == 'ar' ? 'ar' : 'en';
      await setLocaleIdentifier(locale);
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea;
        if (city != null) {
          _locationName = '$city, ${place.country}';
        } else {
          _locationName =
              place.country ?? AppStrings.get('current_location', lang);
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
      _locationName = AppStrings.get('current_location', lang);
    }
  }

  int _getCalculationMethodPriority() {
    if (!_useAutoMethod) return _manualMethod;

    // ─── Region Detection via GPS coordinates ─────────────────────────────
    // The Aladhan API method codes:
    // 1  = Karachi (University of Islamic Sciences, Pakistan)
    // 2  = ISNA (North America)
    // 3  = Muslim World League (MWL)  ← Default for Algeria/Europe
    // 4  = Umm Al Qura (Saudi Arabia & Gulf)
    // 5  = Egyptian General Authority of Survey
    // 9  = Khalid Al Hussayyan (Kuwait by NASA)
    // 10 = Gulf Region
    // 11 = Kuwait
    // 12 = Qatar
    // 13 = Majlis Ugama Islam Singapura (Singapore)
    // 15 = Turkey — Diyanet İşleri Başkanlığı
    // 20 = Tehran
    // 21 = Jafari (Shia)

    // Saudi Arabia & Gulf (lat 12-32, lng 34-60)
    if (_latitude > 12 &&
        _latitude < 32 &&
        _longitude > 34 &&
        _longitude < 60) {
      return 4; // Umm Al Qura
    }

    // Algeria, Morocco, Tunisia, Libya (lat 15-38, lng -18 to 15)
    if (_latitude > 15 &&
        _latitude < 38 &&
        _longitude > -18 &&
        _longitude < 15) {
      return 3; // Muslim World League (MWL) — used officially in Algeria
    }

    // Egypt (lat 22-32, lng 24-35)
    if (_latitude > 22 &&
        _latitude < 32 &&
        _longitude > 24 &&
        _longitude < 35) {
      return 5; // Egyptian
    }

    // Turkey (lat 36-42, lng 26-45)
    if (_latitude > 36 &&
        _latitude < 42 &&
        _longitude > 26 &&
        _longitude < 45) {
      return 15; // Diyanet (Turkey)
    }

    // Europe (lat 35-71, lng -25 to 45)
    if (_latitude > 35 &&
        _latitude < 71 &&
        _longitude > -25 &&
        _longitude < 45) {
      return 3; // Muslim World League — standard in Europe
    }

    // Pakistan, India, Bangladesh (lat 5-37, lng 60-98)
    if (_latitude > 5 && _latitude < 37 && _longitude > 60 && _longitude < 98) {
      return 1; // Karachi
    }

    // Iran (lat 25-40, lng 44-64)
    if (_latitude > 25 &&
        _latitude < 40 &&
        _longitude > 44 &&
        _longitude < 64) {
      return 20; // Tehran
    }

    // Southeast Asia — Malaysia, Indonesia, Singapore (lat -10 to 7, lng 95-141)
    if (_latitude > -10 &&
        _latitude < 7 &&
        _longitude > 95 &&
        _longitude < 141) {
      return 13; // Singapore / MUIS
    }

    // North America (lat 24-50, lng -125 to -66)
    if (_latitude > 24 &&
        _latitude < 75 &&
        _longitude > -168 &&
        _longitude < -52) {
      return 2; // ISNA
    }

    // Sub-Saharan Africa, rest of world → MWL
    return 3;
  }

  Future<void> calculatePrayerTimes() async {
    _error = null;
    final method = _getCalculationMethodPriority();
    final school = _madhab == Madhab.hanafi ? 1 : 0;

    final timings = await AladhanApiService.getMonthlyTimings(
      latitude: _latitude,
      longitude: _longitude,
      method: method,
      school: school,
    );

    if (timings != null && timings.isNotEmpty) {
      final now = DateTime.now();
      // API date format: DD-MM-YYYY
      final todayStr =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

      try {
        final todayData = timings.firstWhere(
            (element) => element['date']['gregorian']['date'] == todayStr,
            orElse: () => timings.isNotEmpty ? timings.last : timings.first);
        _todayTimings = todayData['timings'];
        debugPrint(
            'Prayer times loaded for today: $todayStr | Method: $method | School: $school');
      } catch (e) {
        _error = 'Failed to parse today\'s timings: $e';
        debugPrint(_error);
      }
    } else {
      _error = 'Failed to load timings from API/Cache';
      debugPrint(_error);
    }

    notifyListeners();
    await AdhanScheduler.scheduleNextPrayers();
  }

  Future<void> setMadhab(Madhab madhab) async {
    // Note: To fully apply this, the API service needs to include `&school=${madhab.index}`
    _madhab = madhab;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('madhab_index', madhab.index);
    await calculatePrayerTimes();
  }

  Future<void> setCalculationMethod(int methodCode, bool auto) async {
    _manualMethod = methodCode;
    _useAutoMethod = auto;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calc_method_index', methodCode);
    await prefs.setBool('use_auto_method', auto);
    await calculatePrayerTimes();
  }

  Future<void> refreshLocation(String lang) async {
    await _initLocation(lang);
  }

  String getPrayerName(Prayer prayer, String lang) {
    final translations = {
      'ar': {
        Prayer.fajr: 'الفجر',
        Prayer.sunrise: 'الشروق',
        Prayer.dhuhr: 'الظهر',
        Prayer.asr: 'العصر',
        Prayer.maghrib: 'المغرب',
        Prayer.isha: 'العشاء',
      },
      'en': {
        Prayer.fajr: 'Fajr',
        Prayer.sunrise: 'Sunrise',
        Prayer.dhuhr: 'Dhuhr',
        Prayer.asr: 'Asr',
        Prayer.maghrib: 'Maghrib',
        Prayer.isha: 'Isha',
      },
    };
    return translations[lang]?[prayer] ?? '';
  }

  /// Helper to convert API time string "HH:MM (PKT)" to DateTime
  DateTime? _parseApiTime(String? timeStr) {
    if (timeStr == null) return null;
    try {
      // The API returns time as "05:14 (+03)" or just "05:14"
      final cleanTime = timeStr.split(' ')[0]; // Gets "05:14"
      final parts = cleanTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      debugPrint('Error parsing API time $timeStr: $e');
      return null;
    }
  }

  DateTime? timeForPrayer(Prayer prayer) {
    if (_todayTimings == null) return null;

    switch (prayer) {
      case Prayer.fajr:
        return _parseApiTime(_todayTimings!['Fajr']);
      case Prayer.sunrise:
        return _parseApiTime(_todayTimings!['Sunrise']);
      case Prayer.dhuhr:
        return _parseApiTime(_todayTimings!['Dhuhr']);
      case Prayer.asr:
        return _parseApiTime(_todayTimings!['Asr']);
      case Prayer.maghrib:
        return _parseApiTime(_todayTimings!['Maghrib']);
      case Prayer.isha:
        return _parseApiTime(_todayTimings!['Isha']);
      default:
        return null;
    }
  }

  String formatTime(DateTime time) {
    return DateFormat.jm().format(
        time); // .toLocal() not needed since we build it with DateTime.now()
  }

  Prayer get nextPrayer {
    if (_todayTimings == null) return Prayer.none;
    final now = DateTime.now();

    final timingsList = [
      MapEntry(Prayer.fajr, timeForPrayer(Prayer.fajr)),
      MapEntry(Prayer.sunrise, timeForPrayer(Prayer.sunrise)),
      MapEntry(Prayer.dhuhr, timeForPrayer(Prayer.dhuhr)),
      MapEntry(Prayer.asr, timeForPrayer(Prayer.asr)),
      MapEntry(Prayer.maghrib, timeForPrayer(Prayer.maghrib)),
      MapEntry(Prayer.isha, timeForPrayer(Prayer.isha)),
    ];

    for (var entry in timingsList) {
      if (entry.value != null && entry.value!.isAfter(now)) {
        return entry.key;
      }
    }

    // If all prayers today have passed, next is Fajr tomorrow
    return Prayer.fajr;
  }

  DateTime? get nextPrayerTime {
    final next = nextPrayer;
    if (next == Prayer.none) return null;

    final time = timeForPrayer(next);
    // If next prayer is Fajr and time is *before* now, it means it's tomorrow's Fajr
    if (next == Prayer.fajr && time != null && time.isBefore(DateTime.now())) {
      return time.add(const Duration(days: 1));
    }
    return time;
  }
}
