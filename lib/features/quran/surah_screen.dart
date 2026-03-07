import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import '../../core/app_colors.dart';
import '../../core/locale_provider.dart';
import '../../core/last_reading_provider.dart';
import '../../core/khatma_provider.dart'; // Added this import
import '../../core/luxury_components.dart';
import '../../core/string_extensions.dart';
import '../../core/app_strings.dart';

class SurahScreen extends StatefulWidget {
  final int surahNumber;
  final int initialVerse;

  const SurahScreen({
    super.key,
    required this.surahNumber,
    this.initialVerse = 1,
  });

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  double _fontSize = 28.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialVerse > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToInitialVerse();
      });
    }
  }

  void _scrollToInitialVerse() {
    if (_scrollController.hasClients) {
      // Approximate height of a Verse Card is ~250-300 including padding
      final targetOffset = (widget.initialVerse - 1) * 280.0;
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;
    final lastRead = Provider.of<LastReadingProvider>(context);
    final surahNameAr = quran.getSurahNameArabic(widget.surahNumber);
    final verseCount = quran.getVerseCount(widget.surahNumber);

    return LuxuryScaffold(
      title: surahNameAr,
      actions: [
        _GlassFontSizeButton(
            icon: Icons.add_rounded,
            onTap: () =>
                setState(() => _fontSize = (_fontSize + 2).clamp(20, 50))),
        const SizedBox(width: 8),
        _GlassFontSizeButton(
            icon: Icons.remove_rounded,
            onTap: () =>
                setState(() => _fontSize = (_fontSize - 2).clamp(20, 50))),
        const SizedBox(width: 12),
      ],
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: verseCount + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildHeaderInfo(widget.surahNumber, lang);

          final verseNumber = index;
          final verseText = quran.getVerse(widget.surahNumber, verseNumber);
          final isSaved = lastRead.lastSurah == widget.surahNumber &&
              lastRead.lastVerse == verseNumber;

          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: InkWell(
              onTap: () {
                lastRead.saveQuranPosition(widget.surahNumber, verseNumber);

                // Track page as read for Khatma
                final quranPage =
                    quran.getPageNumber(widget.surahNumber, verseNumber);
                final khatma =
                    Provider.of<KhatmaProvider>(context, listen: false);
                khatma.markPageAsRead(quranPage);

                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.get(
                        lang == 'ar' ? 'saved_at_verse' : 'bookmark_saved',
                        lang)),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor:
                        AppColors.primaryEmerald.withValues(alpha: 0.15),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(24),
              child: LuxuryGlassCard(
                padding: const EdgeInsets.all(24),
                border: isSaved
                    ? Border.all(color: AppColors.royalGold, width: 2)
                    : null,
                child: Column(
                  children: [
                    if (isSaved)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bookmark_rounded,
                                color: AppColors.royalGold, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.get('last_stop_position', lang),
                              style: const TextStyle(
                                  color: AppColors.royalGold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      verseText,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: _fontSize,
                        fontFamily: 'Amiri',
                        height: 2.0,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildVerseLabel(verseNumber, isSaved),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderInfo(int surahNumber, String lang) {
    final revelation = quran.getPlaceOfRevelation(surahNumber);
    final verses = quran.getVerseCount(surahNumber);
    final basmala = surahNumber != 1 && surahNumber != 9;

    return Column(
      children: [
        LuxuryGlassCard(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Column(
            children: [
              Text(
                quran.getSurahName(surahNumber),
                style: const TextStyle(
                    color: AppColors.royalGold,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Text(
                '$verses ${AppStrings.get('verses_count', lang)} • ${lang == 'ar' ? (revelation == 'Makkah' ? AppStrings.get('makkah', lang) : AppStrings.get('madinah', lang)) : revelation}',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
              ),
              if (basmala) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: Colors.white10),
                ),
                const Text(
                  quran.basmala,
                  style: TextStyle(
                      fontFamily: 'Amiri', fontSize: 26, color: Colors.white),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildVerseLabel(int num, bool isSaved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSaved
            ? AppColors.royalGold.withValues(alpha: 0.15)
            : AppColors.royalGold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isSaved
                ? AppColors.royalGold
                : AppColors.royalGold.withValues(alpha: 0.15)),
      ),
      child: Text(
        '$num'.toWesternDigits(),
        style: TextStyle(
            color: isSaved ? Colors.white : AppColors.royalGold,
            fontWeight: FontWeight.bold,
            fontSize: 10),
      ),
    );
  }
}

class _GlassFontSizeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassFontSizeButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.7),
          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        ),
        child: Icon(icon, color: AppColors.royalGold, size: 20),
      ),
    );
  }
}
