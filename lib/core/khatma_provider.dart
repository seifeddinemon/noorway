import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KhatmaProvider extends ChangeNotifier {
  static const String _kIsActive = 'khatma_is_active';
  static const String _kStartDate = 'khatma_start_date';
  static const String _kTargetDays = 'khatma_target_days';
  static const String _kPagesRead = 'khatma_pages_read';
  static const int totalQuranPages = 604;

  bool _isActive = false;
  DateTime? _startDate;
  int _targetDays = 30;
  List<int> _pagesRead = []; // Store specific page numbers read

  bool get isActive => _isActive;
  DateTime? get startDate => _startDate;
  int get targetDays => _targetDays;
  List<int> get pagesRead => _pagesRead;

  int get totalPagesRead => _pagesRead.length;
  double get progressPercentage => totalPagesRead / totalQuranPages;

  int get pagesPerDay {
    if (_targetDays <= 0) return 0;
    return (totalQuranPages / _targetDays).ceil();
  }

  int get expectedPagesToDate {
    if (!_isActive || _startDate == null) return 0;
    final daysElapsed = DateTime.now().difference(_startDate!).inDays;
    // +1 because day 1 should have 1 target quota
    final target = (daysElapsed + 1) * pagesPerDay;
    return target > totalQuranPages ? totalQuranPages : target;
  }

  KhatmaProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _isActive = prefs.getBool(_kIsActive) ?? false;
    final dateStr = prefs.getString(_kStartDate);
    if (dateStr != null) {
      _startDate = DateTime.tryParse(dateStr);
    }
    _targetDays = prefs.getInt(_kTargetDays) ?? 30;

    final pagesStr = prefs.getStringList(_kPagesRead) ?? [];
    _pagesRead =
        pagesStr.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toList();

    notifyListeners();
  }

  Future<void> startKhatma({int targetDays = 30}) async {
    final prefs = await SharedPreferences.getInstance();
    _isActive = true;
    _startDate = DateTime.now();
    _targetDays = targetDays;
    _pagesRead = [];

    await prefs.setBool(_kIsActive, _isActive);
    await prefs.setString(_kStartDate, _startDate!.toIso8601String());
    await prefs.setInt(_kTargetDays, _targetDays);
    await prefs.setStringList(_kPagesRead, []);

    notifyListeners();
  }

  Future<void> togglePageRead(int pageNumber) async {
    if (!_isActive || pageNumber < 1 || pageNumber > totalQuranPages) return;

    final prefs = await SharedPreferences.getInstance();

    if (_pagesRead.contains(pageNumber)) {
      _pagesRead.remove(pageNumber);
    } else {
      _pagesRead.add(pageNumber);
    }

    final strList = _pagesRead.map((e) => e.toString()).toList();
    await prefs.setStringList(_kPagesRead, strList);

    notifyListeners();
  }

  Future<void> markPageAsRead(int pageNumber) async {
    if (!_isActive || pageNumber < 1 || pageNumber > totalQuranPages) return;

    if (!_pagesRead.contains(pageNumber)) {
      final prefs = await SharedPreferences.getInstance();
      _pagesRead.add(pageNumber);

      final strList = _pagesRead.map((e) => e.toString()).toList();
      await prefs.setStringList(_kPagesRead, strList);

      notifyListeners();
    }
  }

  Future<void> stopKhatma() async {
    final prefs = await SharedPreferences.getInstance();
    _isActive = false;
    _startDate = null;
    _pagesRead = [];

    await prefs.remove(_kIsActive);
    await prefs.remove(_kStartDate);
    await prefs.remove(_kTargetDays);
    await prefs.remove(_kPagesRead);

    notifyListeners();
  }
}
