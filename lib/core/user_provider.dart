import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _userName = '';
  static const String _userNameKey = 'user_name';

  UserProvider() {
    _loadUserName();
  }

  String get userName => _userName;
  bool get hasName => _userName.isNotEmpty;

  Future<void> setUserName(String name) async {
    _userName = name.trim();
    notifyListeners();
    await _saveUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString(_userNameKey) ?? '';
    notifyListeners();
  }

  Future<void> _saveUserName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, _userName);
  }
}
