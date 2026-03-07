import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/missed_prayers_provider.dart';
import '../../core/luxury_components.dart';

class MissedPrayersScreen extends StatelessWidget {
  const MissedPrayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;
    final missedPrayers = Provider.of<MissedPrayersProvider>(context);

    return LuxuryScaffold(
      title: AppStrings.get('missed_prayers', lang),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _buildTotalCard(missedPrayers, lang),
          const SizedBox(height: 24),
          _buildPrayerRow(
              context: context,
              provider: missedPrayers,
              prayerKey: 'fajr',
              title: AppStrings.get('fajr', lang),
              count: missedPrayers.fajr,
              icon: Icons.wb_twilight_rounded),
          const SizedBox(height: 12),
          _buildPrayerRow(
              context: context,
              provider: missedPrayers,
              prayerKey: 'dhuhr',
              title: AppStrings.get('dhuhr', lang),
              count: missedPrayers.dhuhr,
              icon: Icons.brightness_high_rounded),
          const SizedBox(height: 12),
          _buildPrayerRow(
              context: context,
              provider: missedPrayers,
              prayerKey: 'asr',
              title: AppStrings.get('asr', lang),
              count: missedPrayers.asr,
              icon: Icons.wb_sunny_rounded),
          const SizedBox(height: 12),
          _buildPrayerRow(
              context: context,
              provider: missedPrayers,
              prayerKey: 'maghrib',
              title: AppStrings.get('maghrib', lang),
              count: missedPrayers.maghrib,
              icon: Icons.nights_stay_rounded),
          const SizedBox(height: 12),
          _buildPrayerRow(
              context: context,
              provider: missedPrayers,
              prayerKey: 'isha',
              title: AppStrings.get('isha', lang),
              count: missedPrayers.isha,
              icon: Icons.dark_mode_rounded),
        ],
      ),
    );
  }

  Widget _buildTotalCard(MissedPrayersProvider provider, String lang) {
    return LuxuryGlassCard(
      gradient: AppColors.premiumEmeraldCardGradient,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.history_rounded,
              color: AppColors.royalGold, size: 48),
          const SizedBox(height: 16),
          Text(
            provider.totalMissed.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.get('missed_prayers', lang),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerRow({
    required BuildContext context,
    required MissedPrayersProvider provider,
    required String prayerKey,
    required String title,
    required int count,
    required IconData icon,
  }) {
    return LuxuryGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.royalGold.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: AppColors.royalGold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              _buildActionButton(
                icon: Icons.remove_rounded,
                onTap: () => provider.decrement(prayerKey),
              ),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: AppColors.royalGold,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildActionButton(
                icon: Icons.add_rounded,
                onTap: () => provider.increment(prayerKey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
