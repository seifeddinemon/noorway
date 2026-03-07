import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MissedPrayersProvider extends ChangeNotifier {
  static const String _kFajr = 'missed_fajr';
  static const String _kDhuhr = 'missed_dhuhr';
  static const String _kAsr = 'missed_asr';
  static const String _kMaghrib = 'missed_maghrib';
  static const String _kIsha = 'missed_isha';

  int _fajr = 0;
  int _dhuhr = 0;
  int _asr = 0;
  int _maghrib = 0;
  int _isha = 0;

  int get fajr => _fajr;
  int get dhuhr => _dhuhr;
  int get asr => _asr;
  int get maghrib => _maghrib;
  int get isha => _isha;

  int get totalMissed => _fajr + _dhuhr + _asr + _maghrib + _isha;

  MissedPrayersProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _fajr = prefs.getInt(_kFajr) ?? 0;
    _dhuhr = prefs.getInt(_kDhuhr) ?? 0;
    _asr = prefs.getInt(_kAsr) ?? 0;
    _maghrib = prefs.getInt(_kMaghrib) ?? 0;
    _isha = prefs.getInt(_kIsha) ?? 0;
    notifyListeners();
  }

  Future<void> increment(String prayer) async {
    final prefs = await SharedPreferences.getInstance();
    switch (prayer) {
      case 'fajr':
        _fajr++;
        await prefs.setInt(_kFajr, _fajr);
        break;
      case 'dhuhr':
        _dhuhr++;
        await prefs.setInt(_kDhuhr, _dhuhr);
        break;
      case 'asr':
        _asr++;
        await prefs.setInt(_kAsr, _asr);
        break;
      case 'maghrib':
        _maghrib++;
        await prefs.setInt(_kMaghrib, _maghrib);
        break;
      case 'isha':
        _isha++;
        await prefs.setInt(_kIsha, _isha);
        break;
    }
    notifyListeners();
  }

  Future<void> decrement(String prayer) async {
    final prefs = await SharedPreferences.getInstance();
    switch (prayer) {
      case 'fajr':
        if (_fajr > 0) {
          _fajr--;
          await prefs.setInt(_kFajr, _fajr);
        }
        break;
      case 'dhuhr':
        if (_dhuhr > 0) {
          _dhuhr--;
          await prefs.setInt(_kDhuhr, _dhuhr);
        }
        break;
      case 'asr':
        if (_asr > 0) {
          _asr--;
          await prefs.setInt(_kAsr, _asr);
        }
        break;
      case 'maghrib':
        if (_maghrib > 0) {
          _maghrib--;
          await prefs.setInt(_kMaghrib, _maghrib);
        }
        break;
      case 'isha':
        if (_isha > 0) {
          _isha--;
          await prefs.setInt(_kIsha, _isha);
        }
        break;
    }
    notifyListeners();
  }
}
