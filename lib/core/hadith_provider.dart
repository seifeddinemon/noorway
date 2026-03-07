import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Hadith {
  final String id;
  final String category;
  final String categoryAr;
  final String text;
  final String textAr;
  final String source;

  Hadith({
    required this.id,
    required this.category,
    required this.categoryAr,
    required this.text,
    required this.textAr,
    required this.source,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'],
      category: json['category'],
      categoryAr: json['category_ar'],
      text: json['text'],
      textAr: json['text_ar'],
      source: json['source'],
    );
  }
}

class HadithProvider extends ChangeNotifier {
  List<Hadith> _hadiths = [];
  bool _isLoading = false;

  List<Hadith> get hadiths => _hadiths;
  bool get isLoading => _isLoading;

  Future<void> loadHadiths() async {
    if (_hadiths.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final String response =
          await rootBundle.loadString('assets/data/hadiths.json');
      final List<dynamic> data = json.decode(response);
      _hadiths = data.map((json) => Hadith.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading hadiths: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<String> getCategories(String lang) {
    return _hadiths
        .map((h) => lang == 'ar' ? h.categoryAr : h.category)
        .toSet()
        .toList();
  }

  List<Hadith> getHadithsByCategory(String category, String lang) {
    return _hadiths
        .where((h) => (lang == 'ar' ? h.categoryAr : h.category) == category)
        .toList();
  }
}
