import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/stories_provider.dart';
import '../../core/luxury_components.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;

    return LuxuryScaffold(
      title: AppStrings.get('stories_of_prophets', lang),
      body: Consumer<StoriesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.royalGold));
          }

          if (provider.error != null) {
            return Center(
                child: Text(provider.error!,
                    style: const TextStyle(color: Colors.white70)));
          }

          final stories = provider.stories;

          if (stories.isEmpty) {
            return Center(
              child: Text(
                AppStrings.get('no_stories_found', lang),
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              final prophetName =
                  lang == 'ar' ? story.prophetNameAr : story.prophetNameEn;
              final title = lang == 'ar' ? story.titleAr : story.titleEn;

              return LuxuryListTile(
                title: prophetName,
                subtitle: title,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.royalGold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.history_edu_rounded,
                      color: AppColors.royalGold, size: 24),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white12, size: 14),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/story_detail',
                    arguments: story.id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
