import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/last_reading_provider.dart';
import '../../core/khatma_provider.dart';
import '../../core/luxury_components.dart';
import 'surah_screen.dart';

class QuranIndexScreen extends StatefulWidget {
  const QuranIndexScreen({super.key});

  @override
  State<QuranIndexScreen> createState() => _QuranIndexScreenState();
}

class _QuranIndexScreenState extends State<QuranIndexScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;
    final lastRead = Provider.of<LastReadingProvider>(context);

    final khatma = Provider.of<KhatmaProvider>(context);

    return LuxuryScaffold(
      title: AppStrings.get('quran', lang),
      body: Column(
        children: [
          _buildKhatmaCard(context, khatma, lang),
          _buildContinueReadingCard(context, lastRead, lang),
          _buildSearchBar(lang),
          Expanded(child: _buildSurahList(context, lang)),
        ],
      ),
    );
  }

  Widget _buildContinueReadingCard(
    BuildContext context,
    LastReadingProvider provider,
    String lang,
  ) {
    if (provider.lastSurah == 0) return const SizedBox.shrink();

    final surahNum = provider.lastSurah;
    final verseNum = provider.lastVerse;
    final surahName = quran.getSurahNameArabic(surahNum);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: LuxuryGlassCard(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.royalGold.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.bookmark_rounded,
                  color: AppColors.royalGold, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get('continue_reading', lang),
                    style: TextStyle(
                      color: AppColors.royalGold.withValues(alpha: 0.15),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$surahName • $verseNum',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            _GlassReadButton(
                onTap: () => _openSurah(context, surahNum, verseNum)),
          ],
        ),
      ),
    );
  }

  Widget _buildKhatmaCard(
      BuildContext context, KhatmaProvider khatma, String lang) {
    if (!khatma.isActive) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: () => _showStartKhatmaDialog(context, khatma, lang),
          child: LuxuryGlassCard(
            gradient: AppColors.premiumEmeraldCardGradient,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.royalGold.withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      color: AppColors.royalGold, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get('start_khatma', lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.get('khatma_desc', lang),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.royalGold),
              ],
            ),
          ),
        ),
      );
    }

    final double progress = khatma.progressPercentage;
    final int todayPagesToRead =
        khatma.expectedPagesToDate - khatma.totalPagesRead;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () => _showStopKhatmaDialog(context, khatma, lang),
        child: LuxuryGlassCard(
          gradient: AppColors.premiumEmeraldCardGradient,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.royalGold),
                      strokeWidth: 4,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppColors.royalGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('khatma_progress', lang),
                      style: const TextStyle(
                        fontFamily: 'NotoKufiArabic',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${khatma.totalPagesRead} / ${KhatmaProvider.totalQuranPages} ${AppStrings.get('pages', lang)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (todayPagesToRead > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          '${AppStrings.get('read_today', lang)}: $todayPagesToRead ${AppStrings.get('pages', lang)}',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.greenAccent.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          AppStrings.get('daily_target_reached', lang),
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStartKhatmaDialog(
      BuildContext context, KhatmaProvider khatma, String lang) {
    showDialog(
        context: context,
        builder: (context) {
          int selectedDays = 30;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.primaryEmerald,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.royalGold, width: 2)),
              title: Text(AppStrings.get('start_khatma', lang),
                  style: const TextStyle(color: AppColors.royalGold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppStrings.get('khatma_target_question', lang),
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 20),
                  DropdownButton<int>(
                    value: selectedDays,
                    dropdownColor: AppColors.primaryEmerald,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedDays = val);
                    },
                    items: [15, 30, 45, 60, 90].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value ${AppStrings.get('days', lang)}'),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppStrings.get('cancel', lang),
                      style: const TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.royalGold),
                  onPressed: () {
                    khatma.startKhatma(targetDays: selectedDays);
                    Navigator.pop(context);
                  },
                  child: Text(AppStrings.get('start', lang),
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          });
        });
  }

  void _showStopKhatmaDialog(
      BuildContext context, KhatmaProvider khatma, String lang) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.primaryEmerald,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.redAccent, width: 2)),
            title: Text(AppStrings.get('stop_khatma', lang),
                style: const TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
            content: Text(AppStrings.get('stop_khatma_desc', lang),
                style: const TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.get('cancel', lang),
                    style: const TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  khatma.stopKhatma();
                  Navigator.pop(context);
                },
                child: Text(AppStrings.get('stop', lang),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
  }

  Widget _buildSearchBar(String lang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: LuxuryGlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: AppStrings.get('search_surah', lang),
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.15)),
            prefixIcon: Icon(Icons.search_rounded,
                color: Colors.white.withValues(alpha: 0.15)),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSurahList(BuildContext context, String lang) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 114,
      itemBuilder: (context, index) {
        final surahNumber = index + 1;
        final nameAr = quran.getSurahNameArabic(surahNumber);
        final nameEn = quran.getSurahName(surahNumber);
        final verses = quran.getVerseCount(surahNumber);
        final place = quran.getPlaceOfRevelation(surahNumber);

        if (_searchQuery.isNotEmpty &&
            !nameAr.contains(_searchQuery) &&
            !nameEn.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return const SizedBox.shrink();
        }

        return LuxuryListTile(
          title: nameAr,
          subtitle: '$nameEn • $verses ${AppStrings.get('verses_count', lang)}',
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.royalGold.withValues(alpha: 0.15)),
            ),
            alignment: Alignment.center,
            child: Text(
              '$surahNumber',
              style: const TextStyle(
                  color: AppColors.royalGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
          trailing: Icon(
            place == 'Makkah' ? Icons.wb_sunny_rounded : Icons.mosque_rounded,
            color: Colors.white.withValues(alpha: 0.15),
            size: 18,
          ),
          onTap: () => _openSurah(context, surahNumber, 1),
        );
      },
    );
  }

  void _openSurah(BuildContext context, int surahNumber, int startVerse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SurahScreen(surahNumber: surahNumber, initialVerse: startVerse),
      ),
    );
  }
}

class _GlassReadButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GlassReadButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.royalGold.withValues(alpha: 0.15)),
          color: AppColors.royalGold.withValues(alpha: 0.15),
        ),
        child: const Icon(Icons.play_arrow_rounded, color: AppColors.royalGold),
      ),
    );
  }
}
