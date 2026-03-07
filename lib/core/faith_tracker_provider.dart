import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaithTrackerProvider with ChangeNotifier {
  final Map<String, List<String>> _activityLog =
      {}; // Date -> List of Completed Activity IDs
  int _streak = 0;
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  int get streak => _streak;

  FaithTrackerProvider() {
    _loadData();
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _streak = prefs.getInt('faith_streak') ?? 0;

    // Simplistic storage for demo, in real app use a database
    final savedLog = prefs.getStringList('faith_activity_log') ?? [];
    for (var entry in savedLog) {
      final parts = entry.split('|');
      if (parts.length == 2) {
        final date = parts[0];
        final activities = parts[1].split(',');
        _activityLog[date] = activities;
      }
    }

    _checkStreak();
    _isLoading = false;
    notifyListeners();
  }

  void _checkStreak() {
    // Logic to verify if streak is still active
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayKey =
        "${yesterday.year}-${yesterday.month}-${yesterday.day}";
    final todayKey = _getTodayKey();

    if (!_activityLog.containsKey(todayKey) &&
        !_activityLog.containsKey(yesterdayKey)) {
      _streak = 0;
    }
  }

  bool isCompleted(String activityId) {
    final today = _getTodayKey();
    return _activityLog[today]?.contains(activityId) ?? false;
  }

  Future<void> toggleActivity(String activityId) async {
    final today = _getTodayKey();
    if (!_activityLog.containsKey(today)) {
      _activityLog[today] = [];
    }

    if (_activityLog[today]!.contains(activityId)) {
      _activityLog[today]!.remove(activityId);
    } else {
      _activityLog[today]!.add(activityId);
    }

    // Update streak if first activity of the day
    if (_activityLog[today]!.length == 1 && _streak == 0) {
      _streak = 1;
    } else if (_activityLog[today]!.length == 1) {
      // Check if yesterday was completed to increment streak
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayKey =
          "${yesterday.year}-${yesterday.month}-${yesterday.day}";
      if (_activityLog.containsKey(yesterdayKey)) {
        _streak++;
      }
    } else if (_activityLog[today]!.isEmpty) {
      // Technically don't break streak immediately on uncheck, but can be added
    }

    await _saveData();
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('faith_streak', _streak);

    List<String> flatLog = [];
    _activityLog.forEach((date, activities) {
      if (activities.isNotEmpty) {
        flatLog.add("$date|${activities.join(',')}");
      }
    });
    await prefs.setStringList('faith_activity_log', flatLog);
  }
}
