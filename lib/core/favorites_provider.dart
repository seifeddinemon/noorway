import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/azkar_item.dart';

class FavoritesProvider extends ChangeNotifier {
  List<AzkarItem> _favorites = [];
  static const String _favKey = 'favorite_azkar';

  FavoritesProvider() {
    _loadFavorites();
  }

  List<AzkarItem> get favorites => _favorites;

  bool isFavorite(AzkarItem item) {
    return _favorites.any((fav) => fav.textAr == item.textAr);
  }

  Future<void> toggleFavorite(AzkarItem item) async {
    final index = _favorites.indexWhere((fav) => fav.textAr == item.textAr);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(item);
    }
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favJson = prefs.getString(_favKey);
    if (favJson != null) {
      final List<dynamic> decoded = json.decode(favJson);
      _favorites = decoded.map((item) => AzkarItem.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(
      _favorites
          .map(
            (item) => {
              'type': item.type,
              'text_ar': item.textAr,
              'text_en': item.textEn,
              'source': item.source,
              'count': item.count,
            },
          )
          .toList(),
    );
    await prefs.setString(_favKey, encoded);
  }
}
