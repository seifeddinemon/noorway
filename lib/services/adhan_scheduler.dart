import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/aladhan_api_service.dart';
import '../core/prayer_times_provider.dart';
import '../services/local_notification_service.dart';
import '../core/app_strings.dart';

class AdhanScheduler {
  static final LocalNotificationService _notificationService =
      LocalNotificationService();

  static Future<void> scheduleNextPrayers() async {
    try {
      if (kDebugMode) print('Starting Adhan Scheduling...');

      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      final bool globalEnabled = prefs.getBool('global_adhan_enabled') ?? true;
      if (!globalEnabled) {
        if (kDebugMode) {
          print('Global Adhan disabled, cancelling all notifications');
        }
        await _notificationService.cancelAllNotifications();
        return;
      }

      final lat = prefs.getDouble('lat');
      final lng = prefs.getDouble('lng');
      if (lat == null || lng == null) {
        if (kDebugMode) print('Location not set, cannot schedule Adhan');
        return;
      }

      final bool useAutoMethod = prefs.getBool('use_auto_method') ?? true;
      final int manualMethodIndex = prefs.getInt('calc_method_index') ?? 3;
      final int method =
          useAutoMethod ? _autoDetectMethod(lat, lng) : manualMethodIndex;
      final String lang = prefs.getString('app_locale') ?? 'ar';

      // Load timings
      final timings = await AladhanApiService.getMonthlyTimings(
        latitude: lat,
        longitude: lng,
        method: method,
      );

      if (timings == null || timings.isEmpty) {
        if (kDebugMode) print('Failed to fetch timings for scheduling.');
        return;
      }

      await _notificationService.cancelAllNotifications();

      final now = DateTime.now();
      int scheduleCount = 0;
      final prayersToCheck = [
        Prayer.fajr,
        Prayer.sunrise,
        Prayer.dhuhr,
        Prayer.asr,
        Prayer.maghrib,
        Prayer.isha
      ];

      // Schedule for the next 7 days
      for (int i = 0; i < 7; i++) {
        final targetDate = now.add(Duration(days: i));
        final targetDateStr =
            '${targetDate.day.toString().padLeft(2, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.year}';

        Map<String, dynamic>? dayTimingsStr;
        try {
          final dayData = timings.firstWhere((element) =>
              element['date']['gregorian']['date'] == targetDateStr);
          dayTimingsStr = dayData['timings'];
        } catch (_) {
          // If the day is not in the current month's fetched data
          continue;
        }

        if (dayTimingsStr == null) continue;

        for (var p in prayersToCheck) {
          final timeName = _getApiNameForPrayer(p);
          if (timeName.isEmpty) continue; // Skip Prayer.none

          final timeStr = dayTimingsStr[timeName];
          final pTime = _parseApiTimeOffset(timeStr, targetDate);

          if (pTime != null && pTime.isAfter(now)) {
            final bool prayerAdhanEnabled = prefs.getBool('adhan_${p.name}') ??
                (p != Prayer.sunrise); // Typically sunrise adhan is off default

            if (prayerAdhanEnabled) {
              final id = _generateNotificationId(targetDate, p);
              final name = _getPrayerName(p, lang);
              final String nextPrayerStr = AppStrings.get('next_prayer', lang);
              final String body = '$nextPrayerStr $name';

              // Unique payload to identify the notification easily if tapped
              final payload = '${p.name}_${targetDate.millisecondsSinceEpoch}';

              await _notificationService.scheduleAdhan(
                id: id,
                title: name,
                body: body,
                scheduledDate: pTime,
                payload: payload,
                playSound: true,
              );
              scheduleCount++;
            }
          }
        }
      }

      if (kDebugMode) {
        print(
            'Successfully scheduled $scheduleCount Adhans for the next 7 days.');
      }
    } catch (e) {
      if (kDebugMode) print('Error in AdhanScheduler: $e');
    }
  }

  static int _generateNotificationId(DateTime date, Prayer p) {
    // Unique ID based on Date and Prayer type
    // e.g. 2026 03 05 + Prayer Index
    final int baseDate = date.year * 10000 + date.month * 100 + date.day;
    return baseDate * 10 + p.index;
  }

  static DateTime? _parseApiTimeOffset(String? timeStr, DateTime targetDate) {
    if (timeStr == null) return null;
    try {
      final cleanTime = timeStr.split(' ')[0];
      final parts = cleanTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(
          targetDate.year, targetDate.month, targetDate.day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  static String _getApiNameForPrayer(Prayer p) {
    switch (p) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return '';
    }
  }

  static int _autoDetectMethod(double lat, double lng) {
    if (lat > 12 && lat < 32 && lng > 34 && lng < 60) return 4;
    if (lat > 15 && lat < 38 && lng > -18 && lng < 15) return 3;
    if (lat > 22 && lat < 32 && lng > 24 && lng < 35) return 5;
    if (lat > 36 && lat < 42 && lng > 26 && lng < 45) return 15;
    if (lat > 35 && lat < 71 && lng > -25 && lng < 45) return 3;
    if (lat > 5 && lat < 37 && lng > 60 && lng < 98) return 1;
    if (lat > 25 && lat < 40 && lng > 44 && lng < 64) return 20;
    if (lat > -10 && lat < 7 && lng > 95 && lng < 141) return 13;
    if (lat > 24 && lat < 75 && lng > -168 && lng < -52) return 2;
    return 3;
  }

  static String _getPrayerName(Prayer prayer, String lang) {
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
}
