import 'package:flutter/foundation.dart';

class InspirationModel {
  final String arabicText;
  final String englishText;
  final String arabicSource;
  final String englishSource;
  final String type; // 'quran', 'hadith', 'dua'

  const InspirationModel({
    required this.arabicText,
    required this.englishText,
    required this.arabicSource,
    required this.englishSource,
    required this.type,
  });
}

class InspirationProvider extends ChangeNotifier {
  static const List<InspirationModel> _inspirations = [
    InspirationModel(
      arabicText: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      englishText: 'Verily, with every difficulty, there is relief.',
      arabicSource: 'الشرح: 6',
      englishSource: 'Al-Inshirah: 6',
      type: 'quran',
    ),
    InspirationModel(
      arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ',
      englishText: 'O Allah, I ask You for pardon and well-being.',
      arabicSource: 'دعاء',
      englishSource: 'Dua',
      type: 'dua',
    ),
    InspirationModel(
      arabicText: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
      englishText: 'Allah does not burden a soul beyond that it can bear.',
      arabicSource: 'البقرة: 286',
      englishSource: 'Al-Baqarah: 286',
      type: 'quran',
    ),
    InspirationModel(
      arabicText: 'ادْعُونِي أَسْتَجِبْ لَكُمْ',
      englishText: 'Call upon Me; I will respond to you.',
      arabicSource: 'غافر: 60',
      englishSource: 'Ghafir: 60',
      type: 'quran',
    ),
    InspirationModel(
      arabicText: 'مَنْ لَا يَرْحَمْ لَا يُرْحَمْ',
      englishText: 'He who does not show mercy will not be shown mercy.',
      arabicSource: 'حديث شريف',
      englishSource: 'Hadith',
      type: 'hadith',
    ),
  ];

  InspirationModel get dailyInspiration {
    // Select an inspiration based on the current day of the year
    // This ensures every user sees the same message on the same day,
    // and it only changes at midnight.
    final now = DateTime.now();
    final dayOfYear = int.parse(
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}');
    final index = dayOfYear % _inspirations.length;
    return _inspirations[index];
  }
}
