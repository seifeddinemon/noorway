import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/hadith_provider.dart';
import '../../core/luxury_components.dart';

class HadithsScreen extends StatefulWidget {
  const HadithsScreen({super.key});

  @override
  State<HadithsScreen> createState() => _HadithsScreenState();
}

class _HadithsScreenState extends State<HadithsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<HadithProvider>(context, listen: false).loadHadiths();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;
    final hadithProvider = Provider.of<HadithProvider>(context);

    return LuxuryScaffold(
      title: AppStrings.get('hadiths', lang),
      body: hadithProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.royalGold))
          : _buildCategoryGrid(context, hadithProvider, lang),
    );
  }

  Widget _buildCategoryGrid(
      BuildContext context, HadithProvider provider, String lang) {
    final categories = provider.getCategories(lang);

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return LuxuryGlassCard(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: () =>
                _showHadithsByCategory(context, provider, category, lang),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_stories_rounded,
                    color: AppColors.royalGold, size: 32),
                const SizedBox(height: 12),
                Text(
                  category,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHadithsByCategory(BuildContext context, HadithProvider provider,
      String category, String lang) {
    final hadiths = provider.getHadithsByCategory(category, lang);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HadithListScreen(
          category: category,
          hadiths: hadiths,
          lang: lang,
        ),
      ),
    );
  }
}

class HadithListScreen extends StatelessWidget {
  final String category;
  final List<Hadith> hadiths;
  final String lang;

  const HadithListScreen({
    super.key,
    required this.category,
    required this.hadiths,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return LuxuryScaffold(
      title: category,
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: hadiths.length,
        itemBuilder: (context, index) {
          final hadith = hadiths[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: LuxuryGlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == 'ar' ? hadith.textAr : hadith.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.6,
                      fontWeight:
                          lang == 'ar' ? FontWeight.w600 : FontWeight.normal,
                      fontFamily: lang == 'ar' ? 'Amiri' : 'Outfit',
                    ),
                    textAlign: lang == 'ar' ? TextAlign.right : TextAlign.left,
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hadith.source,
                        style: const TextStyle(
                          color: AppColors.royalGold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.format_quote_rounded,
                          color: Colors.white12),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
