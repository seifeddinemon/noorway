import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/prayer_times_provider.dart';
import '../../core/locale_provider.dart';
import '../../core/luxury_components.dart';
import '../../core/string_extensions.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  bool _isServiceRunning = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _toggleService(bool value) async {
    setState(() => _isServiceRunning = value);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;
    final prayerProvider = Provider.of<PrayerTimesProvider>(context);

    return LuxuryScaffold(
      title: AppStrings.get('prayer_times', lang),
      body: prayerProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.royalGold))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                _buildHeader(prayerProvider, lang),
                const SizedBox(height: 32),
                _buildStickyNotificationToggle(lang),
                const SizedBox(height: 24),
                _buildPrayerList(prayerProvider, lang),
              ],
            ),
    );
  }

  Widget _buildHeader(PrayerTimesProvider provider, String lang) {
    return LuxuryGlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.location_on_rounded,
              color: AppColors.royalGold, size: 28),
          const SizedBox(height: 12),
          Text(
            provider.locationName,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat.yMMMMd(lang).format(DateTime.now()),
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyNotificationToggle(String lang) {
    return LuxuryGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SwitchListTile(
        title: Text(
          AppStrings.get('sticky_notification', lang),
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
        ),
        subtitle: Text(
          AppStrings.get('sticky_notification_desc', lang),
          style: TextStyle(
              fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
        ),
        activeThumbColor: AppColors.royalGold,
        value: _isServiceRunning,
        onChanged: _toggleService,
      ),
    );
  }

  Widget _buildPrayerList(PrayerTimesProvider provider, String lang) {
    final prayers = [
      Prayer.fajr,
      Prayer.sunrise,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];

    return Column(
      children:
          prayers.map((p) => _buildPrayerItem(provider, p, lang)).toList(),
    );
  }

  Widget _buildPrayerItem(
      PrayerTimesProvider provider, Prayer prayer, String lang) {
    final time = provider.timeForPrayer(prayer);
    final isNext = provider.nextPrayer == prayer;
    final name = provider.getPrayerName(prayer, lang);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LuxuryGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isNext ? AppColors.royalGold : Colors.white)
                        .withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getPrayerIcon(prayer),
                    color: isNext
                        ? AppColors.royalGold
                        : Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: isNext ? FontWeight.w900 : FontWeight.w600,
                    color: isNext ? AppColors.royalGold : Colors.white,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time != null
                      ? provider.formatTime(time).toWesternDigits()
                      : '--:--',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isNext
                        ? AppColors.royalGold
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                if (isNext)
                  Text(
                    AppStrings.get('next_prayer', lang),
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.royalGold,
                        fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPrayerIcon(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return Icons.wb_twilight_rounded;
      case Prayer.sunrise:
        return Icons.wb_sunny_outlined;
      case Prayer.dhuhr:
        return Icons.wb_sunny_rounded;
      case Prayer.asr:
        return Icons.wb_cloudy_rounded;
      case Prayer.maghrib:
        return Icons.nightlight_round;
      case Prayer.isha:
        return Icons.bedtime_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }
}
