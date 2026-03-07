import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/luxury_components.dart';
import 'azkar_list_screen.dart';

class AzkarCategoriesScreen extends StatelessWidget {
  const AzkarCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;

    final List<Map<String, dynamic>> categories = [
      {
        'title': AppStrings.get('morning_azkar', lang),
        'icon': Icons.wb_sunny_rounded,
        'type': 'morning',
        'color': AppColors.royalGold,
      },
      {
        'title': AppStrings.get('evening_azkar', lang),
        'icon': Icons.nights_stay_rounded,
        'type': 'evening',
        'color': AppColors.vibrantGold,
      },
      {
        'title': AppStrings.get('after_prayer_azkar', lang),
        'icon': Icons.mosque_rounded,
        'type': 'after_prayer',
        'color': AppColors.softGoldHighlight,
      },
      {
        'title': AppStrings.get('sleep_azkar', lang),
        'icon': Icons.hotel_rounded,
        'type': 'sleep',
        'color': AppColors.royalGold.withValues(alpha: 0.8),
      },
      {
        'title': AppStrings.get('general_duas', lang),
        'icon': Icons.back_hand_rounded,
        'type': 'general',
        'color': AppColors.royalGold.withValues(alpha: 0.6),
      },
      {
        'title': AppStrings.get('hadiths', lang),
        'icon': Icons.menu_book_rounded,
        'type': 'hadiths',
        'color': AppColors.royalGold.withValues(alpha: 0.9),
      },
    ];

    return LuxuryScaffold(
      title: AppStrings.get('azkar', lang),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return LuxuryListTile(
            title: cat['title'] as String,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (cat['color'] as Color).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(cat['icon'] as IconData,
                  color: cat['color'] as Color, size: 24),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white12, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AzkarListScreen(
                    categoryType: cat['type'] as String,
                    categoryTitle: cat['title'] as String,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
