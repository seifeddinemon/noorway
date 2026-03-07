import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/favorites_provider.dart';
import '../../data/models/azkar_item.dart';
import '../../core/luxury_components.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;

    return LuxuryScaffold(
      title: AppStrings.get('favorites', lang),
      body: Consumer<FavoritesProvider>(
        builder: (context, favProvider, child) {
          final favorites = favProvider.favorites;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border_rounded,
                      size: 80, color: Colors.white12),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.get('no_favorites_yet', lang),
                    style: const TextStyle(color: Colors.white38, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return _buildAzkarCard(
                  context, favorites[index], favProvider, lang);
            },
          );
        },
      ),
    );
  }

  Widget _buildAzkarCard(BuildContext context, AzkarItem item,
      FavoritesProvider favProvider, String lang) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LuxuryGlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.textAr,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.6,
                  fontFamily: 'Amiri'),
            ),
            if (lang == 'en') ...[
              const SizedBox(height: 16),
              Text(
                item.textEn,
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.15),
                    height: 1.5),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.source,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.royalGold,
                        fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_rounded,
                      color: Colors.redAccent),
                  onPressed: () => favProvider.toggleFavorite(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
