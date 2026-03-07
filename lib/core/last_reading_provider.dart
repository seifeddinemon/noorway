import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LastReadingProvider extends ChangeNotifier {
  final Map<String, int> _lastIndices = {};
  static const String _prefPrefix = 'last_read_';

  LastReadingProvider() {
    _loadPositions();
  }

  int getLastIndex(String category) {
    return _lastIndices[category] ?? 0;
  }

  // Quran specific
  int get lastSurah => _lastIndices['quran_surah'] ?? 1;
  int get lastVerse => _lastIndices['quran_verse'] ?? 1;

  Future<void> savePosition(String category, int index) async {
    _lastIndices[category] = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefPrefix$category', index);
  }

  Future<void> saveQuranPosition(int surah, int verse) async {
    _lastIndices['quran_surah'] = surah;
    _lastIndices['quran_verse'] = verse;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_prefPrefix}quran_surah', surah);
    await prefs.setInt('${_prefPrefix}quran_verse', verse);
  }

  Future<void> _loadPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_prefPrefix));
    for (final key in keys) {
      final category = key.replaceFirst(_prefPrefix, '');
      _lastIndices[category] = prefs.getInt(key) ?? 0;
    }
    notifyListeners();
  }
}
