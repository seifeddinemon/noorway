import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noorway/core/prayer_times_provider.dart';
import '../services/adhan_scheduler.dart';

class AdhanSettingsProvider extends ChangeNotifier {
  final Map<Prayer, bool> _enabledPrayers = {
    Prayer.fajr: true,
    Prayer.dhuhr: true,
    Prayer.asr: true,
    Prayer.maghrib: true,
    Prayer.isha: true,
  };

  bool _isGlobalAdhanEnabled = true;
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  bool get isGlobalAdhanEnabled => _isGlobalAdhanEnabled;

  AdhanSettingsProvider() {
    _loadSettings();
  }

  bool isPrayerEnabled(Prayer prayer) {
    if (!_isGlobalAdhanEnabled) return false;
    return _enabledPrayers[prayer] ?? true;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _isGlobalAdhanEnabled = prefs.getBool('global_adhan_enabled') ?? true;

    for (var prayer in _enabledPrayers.keys) {
      _enabledPrayers[prayer] = prefs.getBool('adhan_${prayer.name}') ?? true;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleGlobalAdhan(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('global_adhan_enabled', value);
    _isGlobalAdhanEnabled = value;
    notifyListeners();
    await AdhanScheduler.scheduleNextPrayers();
  }

  Future<void> togglePrayerAdhan(Prayer prayer, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adhan_${prayer.name}', value);
    _enabledPrayers[prayer] = value;
    notifyListeners();
    await AdhanScheduler.scheduleNextPrayers();
  }
}
