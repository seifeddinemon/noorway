import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/stories_provider.dart';
import '../../core/luxury_components.dart';

class StoryDetailScreen extends StatelessWidget {
  const StoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;
    final storyId = ModalRoute.of(context)?.settings.arguments as String?;

    if (storyId == null) {
      return LuxuryScaffold(
          title: '',
          body: Center(
              child: Text(AppStrings.get('story_not_found', lang),
                  style: const TextStyle(color: Colors.white70))));
    }

    final provider = Provider.of<StoriesProvider>(context, listen: false);
    final story = provider.getStoryById(storyId);

    if (story == null) {
      return LuxuryScaffold(
          title: '',
          body: Center(
              child: Text(AppStrings.get('story_not_found', lang),
                  style: const TextStyle(color: Colors.white70))));
    }

    final prophetName =
        lang == 'ar' ? story.prophetNameAr : story.prophetNameEn;
    final title = lang == 'ar' ? story.titleAr : story.titleEn;
    final content = lang == 'ar' ? story.contentAr : story.contentEn;

    return LuxuryScaffold(
      title: prophetName,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LuxuryGlassCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.royalGold,
                      height: 1.4,
                      fontFamily: 'Amiri',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(color: Colors.white10),
                  ),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 19,
                      height: 1.9,
                      color: Colors.white,
                      fontFamily: 'Amiri',
                    ),
                    textAlign:
                        lang == 'ar' ? TextAlign.justify : TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
