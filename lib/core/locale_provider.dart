import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  static const String _localeKey = 'app_locale';

  LocaleProvider() {
    _loadLocale();
  }

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> changeLocale(Locale newLocale) async {
    if (_locale.languageCode != newLocale.languageCode) {
      _locale = newLocale;
      notifyListeners();
      await _saveLocale();
    }
  }

  Future<void> toggleLocale() async {
    if (_locale.languageCode == 'ar') {
      _locale = const Locale('en');
    } else {
      _locale = const Locale('ar');
    }
    notifyListeners();
    await _saveLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_localeKey);
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> _saveLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, _locale.languageCode);
  }
}
