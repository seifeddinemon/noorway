import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/adhan_settings_provider.dart';
import '../../core/prayer_times_provider.dart';
import '../../core/luxury_components.dart';
import '../../services/adhan_scheduler.dart';

class AdhanSettingsScreen extends StatefulWidget {
  const AdhanSettingsScreen({super.key});

  @override
  State<AdhanSettingsScreen> createState() => _AdhanSettingsScreenState();
}

class _AdhanSettingsScreenState extends State<AdhanSettingsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingTest = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudioTest() async {
    if (_isPlayingTest) {
      await _audioPlayer.stop();
      setState(() => _isPlayingTest = false);
    } else {
      await _audioPlayer.play(AssetSource('audio/adhan.mp3'));
      setState(() => _isPlayingTest = true);
      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) setState(() => _isPlayingTest = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;

    return LuxuryScaffold(
      title: AppStrings.get('adhan_settings', lang),
      body: Consumer2<AdhanSettingsProvider, PrayerTimesProvider>(
        builder: (context, adhanProvider, prayerProvider, child) {
          if (adhanProvider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.royalGold));
          }

          final prayers = [
            Prayer.fajr,
            Prayer.sunrise,
            Prayer.dhuhr,
            Prayer.asr,
            Prayer.maghrib,
            Prayer.isha,
          ];

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              _buildGlobalToggle(adhanProvider, lang),
              const SizedBox(height: 24),
              _buildUtilityButtons(lang),
              const SizedBox(height: 32),
              Text(
                AppStrings.get('custom_prayer_settings', lang),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.royalGold),
              ),
              const SizedBox(height: 16),
              ...prayers.map((prayer) {
                if (prayer == Prayer.sunrise) return const SizedBox.shrink();
                final isEnabled = adhanProvider.isPrayerEnabled(prayer);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LuxuryGlassCard(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: SwitchListTile(
                      title: Text(
                        prayerProvider.getPrayerName(prayer, lang),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isEnabled ? Colors.white : Colors.white24,
                        ),
                      ),
                      secondary: Icon(
                        isEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: isEnabled ? AppColors.royalGold : Colors.white12,
                      ),
                      value: isEnabled,
                      onChanged: adhanProvider.isGlobalAdhanEnabled
                          ? (val) =>
                              adhanProvider.togglePrayerAdhan(prayer, val)
                          : null,
                      activeThumbColor: AppColors.royalGold,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 32),
              Text(
                AppStrings.get('calculation_settings', lang),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.royalGold),
              ),
              const SizedBox(height: 16),
              _buildLocationRefreshTile(prayerProvider, lang),
              const SizedBox(height: 12),
              _buildMadhabSelection(prayerProvider, lang),
              const SizedBox(height: 12),
              _buildCalculationMethodSelection(prayerProvider, lang),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLocationRefreshTile(
      PrayerTimesProvider prayerProvider, String lang) {
    return LuxuryGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('refresh_location', lang),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  AppStrings.get('precision_location_desc', lang),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => prayerProvider.refreshLocation(lang),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.royalGold,
              foregroundColor: AppColors.primaryEmerald,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Icon(Icons.my_location_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildMadhabSelection(
      PrayerTimesProvider prayerProvider, String lang) {
    return LuxuryGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('madhab', lang),
            style: const TextStyle(
                color: AppColors.royalGold,
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildChoiceChip(
                  label: AppStrings.get('madhab_shafi', lang),
                  isSelected: prayerProvider.madhab == Madhab.shafi,
                  onSelected: (val) {
                    if (val) prayerProvider.setMadhab(Madhab.shafi);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChoiceChip(
                  label: AppStrings.get('madhab_hanafi', lang),
                  isSelected: prayerProvider.madhab == Madhab.hanafi,
                  onSelected: (val) {
                    if (val) prayerProvider.setMadhab(Madhab.hanafi);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationMethodSelection(
      PrayerTimesProvider prayerProvider, String lang) {
    return LuxuryGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('calc_method', lang),
            style: const TextStyle(
                color: AppColors.royalGold,
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: prayerProvider.useAutoMethod
                  ? -1 // Using -1 as a code for 'auto'
                  : prayerProvider.manualMethod,
              dropdownColor: AppColors.primaryEmerald,
              isExpanded: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: [
                DropdownMenuItem(
                  value: -1,
                  child: Text(AppStrings.get('calc_method_auto', lang)),
                ),
                const DropdownMenuItem(
                    value: 3, child: Text('MUSLIM WORLD LEAGUE')),
                const DropdownMenuItem(value: 4, child: Text('UMM AL-QURA')),
                const DropdownMenuItem(
                    value: 2, child: Text('ISNA (NORTH AMERICA)')),
                const DropdownMenuItem(value: 5, child: Text('EGYPTIAN')),
                const DropdownMenuItem(value: 1, child: Text('KARACHI')),
              ],
              onChanged: (val) {
                if (val == null) return;
                if (val == -1) {
                  prayerProvider.setCalculationMethod(
                      prayerProvider.manualMethod, true);
                } else {
                  prayerProvider.setCalculationMethod(val, false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.royalGold,
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryEmerald : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildGlobalToggle(AdhanSettingsProvider adhanProvider, String lang) {
    return LuxuryGlassCard(
      padding: const EdgeInsets.all(24),
      gradient: LinearGradient(
        colors: [
          AppColors.royalGold.withValues(alpha: 0.15),
          AppColors.royalGold.withValues(alpha: 0.15)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_rounded,
                  color: AppColors.royalGold, size: 28),
              const SizedBox(width: 16),
              Text(
                AppStrings.get('enable_all_adhan', lang),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
          Switch(
            value: adhanProvider.isGlobalAdhanEnabled,
            onChanged: (val) => adhanProvider.toggleGlobalAdhan(val),
            activeThumbColor: AppColors.royalGold,
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityButtons(String lang) {
    return Row(
      children: [
        Expanded(
          child: LuxuryGlassCard(
            padding: EdgeInsets.zero,
            child: InkWell(
              onTap: () async {
                await AdhanScheduler.scheduleNextPrayers();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            AppStrings.get('notification_restarted', lang))),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    const Icon(Icons.refresh_rounded,
                        color: AppColors.royalGold),
                    const SizedBox(height: 8),
                    Text(AppStrings.get('fix_status', lang),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LuxuryGlassCard(
            padding: EdgeInsets.zero,
            child: InkWell(
              onTap: _toggleAudioTest,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Icon(
                        _isPlayingTest
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.royalGold),
                    const SizedBox(height: 8),
                    Text(
                      _isPlayingTest
                          ? AppStrings.get('stop_test', lang)
                          : AppStrings.get('test_adhan', lang),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
