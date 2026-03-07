import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/luxury_components.dart';

class MoodGuideScreen extends StatefulWidget {
  const MoodGuideScreen({super.key});

  @override
  State<MoodGuideScreen> createState() => _MoodGuideScreenState();
}

class _MoodGuideScreenState extends State<MoodGuideScreen> {
  String? _selectedMood;

  final Map<String, Map<String, dynamic>> _soulHealingContent = {
    'feeling_anxious': {
      'ayah': {
        'ar': 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
        'en':
            'Unquestionably, by the remembrance of Allah do hearts find rest.',
        'ref': '13:28'
      },
      'dhikr': {
        'ar': 'لا حول ولا قوة إلا بالله',
        'en': 'There is no power nor might except with Allah.',
      },
      'color': Colors.cyanAccent,
    },
    'feeling_sad': {
      'ayah': {
        'ar': 'لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا',
        'en': 'Do not grieve; indeed Allah is with us.',
        'ref': '9:40'
      },
      'dhikr': {
        'ar': 'يا حي يا قيوم برحمتك أستغيث',
        'en': 'O Ever-Living, O Self-Sustaining, by Your mercy I seek help.',
      },
      'color': Colors.indigoAccent,
    },
    'feeling_grateful': {
      'ayah': {
        'ar': 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
        'en': 'If you are grateful, I will surely increase you.',
        'ref': '14:7'
      },
      'dhikr': {
        'ar': 'الحمد لله حمداً كثيراً',
        'en': 'Praise be to Allah, a praise abundant.',
      },
      'color': Colors.orangeAccent,
    },
    'seeking_guidance': {
      'ayah': {
        'ar': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
        'en': 'Guide us to the straight path.',
        'ref': '1:6'
      },
      'dhikr': {
        'ar': 'اللهم اهدني وسددني',
        'en': 'O Allah, guide me and keep me firm.',
      },
      'color': AppColors.royalGold,
    }
  };

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;

    return LuxuryScaffold(
      title: AppStrings.get('soul_healing', lang),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              AppStrings.get('how_is_your_heart', lang),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 32),
            _buildMoodGrid(lang),
            if (_selectedMood != null) ...[
              const SizedBox(height: 48),
              _buildSoulContent(lang),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoodGrid(String lang) {
    final moods = _soulHealingContent.keys.toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: moods.length,
      itemBuilder: (context, index) {
        final mood = moods[index];
        final isSelected = _selectedMood == mood;
        return LuxuryGlassCard(
          padding: EdgeInsets.zero,
          border: isSelected
              ? Border.all(color: AppColors.royalGold, width: 2)
              : null,
          child: InkWell(
            onTap: () => setState(() => _selectedMood = mood),
            child: Center(
              child: Text(
                AppStrings.get(mood, lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? AppColors.royalGold : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSoulContent(String lang) {
    final content = _soulHealingContent[_selectedMood!]!;
    final ayah = content['ayah'];
    final dhikr = content['dhikr'];

    return Column(
      children: [
        LuxuryGlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.auto_awesome_outlined,
                  color: AppColors.royalGold, size: 32),
              const SizedBox(height: 16),
              Text(
                ayah[lang],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.8,
                  fontFamily: 'Amiri',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                ayah['ref'],
                style: TextStyle(
                    color: AppColors.royalGold.withValues(alpha: 0.15), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        LuxuryGlassCard(
          padding: const EdgeInsets.all(24),
          gradient: LinearGradient(
            colors: [
              (content['color'] as Color).withValues(alpha: 0.15),
              Colors.transparent,
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite_rounded, color: AppColors.royalGold),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('suggested_dhikr', lang),
                      style: const TextStyle(
                          color: AppColors.royalGold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dhikr[lang],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
