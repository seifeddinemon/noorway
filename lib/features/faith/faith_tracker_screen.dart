import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/faith_tracker_provider.dart';
import '../../core/luxury_components.dart';

class FaithTrackerScreen extends StatelessWidget {
  const FaithTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;
    final tracker = Provider.of<FaithTrackerProvider>(context);

    final List<Map<String, String>> habits = [
      {'id': 'fajr', 'name': AppStrings.get('fajr_prayer', lang)},
      {'id': 'dhuhr', 'name': AppStrings.get('dhuhr_prayer', lang)},
      {'id': 'asr', 'name': AppStrings.get('asr_prayer', lang)},
      {'id': 'maghrib', 'name': AppStrings.get('maghrib_prayer', lang)},
      {'id': 'isha', 'name': AppStrings.get('isha_prayer', lang)},
      {'id': 'quran', 'name': AppStrings.get('quran_reading', lang)},
      {'id': 'azkar', 'name': AppStrings.get('daily_azkar', lang)},
    ];

    return LuxuryScaffold(
      title: AppStrings.get('faith_journey', lang),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Streak Card
          _buildStreakCard(tracker, lang),
          const SizedBox(height: 32),

          Text(
            AppStrings.get('todays_achievements', lang),
            style: const TextStyle(
                color: AppColors.royalGold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),

          ...habits.map((habit) => _buildHabitItem(habit, tracker, lang)),
        ],
      ),
    );
  }

  Widget _buildStreakCard(FaithTrackerProvider tracker, String lang) {
    return LuxuryGlassCard(
      padding: const EdgeInsets.all(32),
      gradient: LinearGradient(
        colors: [
          AppColors.royalGold.withValues(alpha: 0.15),
          AppColors.primaryEmerald.withValues(alpha: 0.15),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome_rounded,
              color: AppColors.royalGold, size: 48),
          const SizedBox(height: 16),
          Text(
            AppStrings.get('daily_streak', lang),
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${tracker.streak} ${AppStrings.get('days', lang)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 4,
            width: 100,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitItem(
      Map<String, String> habit, FaithTrackerProvider tracker, String lang) {
    final bool isDone = tracker.isCompleted(habit['id']!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LuxuryGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border:
            isDone ? Border.all(color: AppColors.royalGold, width: 1.5) : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                habit['name']!,
                style: TextStyle(
                  color: isDone ? AppColors.royalGold : Colors.white,
                  fontSize: 18,
                  fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            Checkbox(
              value: isDone,
              onChanged: (_) => tracker.toggleActivity(habit['id']!),
              activeColor: AppColors.royalGold,
              checkColor: AppColors.primaryEmerald,
              side: const BorderSide(color: Colors.white24, width: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
          ],
        ),
      ),
    );
  }
}
