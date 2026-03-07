import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/prayer_times_provider.dart';
import '../../../core/inspiration_provider.dart';
import '../../features/quran/quran_index_screen.dart';
import '../../features/tasbeeh/tasbeeh_screen.dart';
import '../../core/quiz_provider.dart';
import '../../core/luxury_components.dart';
import '../../core/user_provider.dart';
import '../../core/string_extensions.dart';
import '../../core/theme_provider.dart';

class PremiumDashboardScreen extends StatefulWidget {
  const PremiumDashboardScreen({super.key});

  @override
  State<PremiumDashboardScreen> createState() => _PremiumDashboardScreenState();
}

class _PremiumDashboardScreenState extends State<PremiumDashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  // Ambient breathing animation
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  // Staggered entrance animation
  late AnimationController _entranceController;
  late Animation<double> _headerAnim;
  late Animation<double> _cardAnim;
  late Animation<double> _gridAnim;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(
            parent: _breathController, curve: Curves.easeInOutSine));

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerAnim = CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic));
    _cardAnim = CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic));
    _gridAnim = CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _breathController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;
    final prayerProvider = Provider.of<PrayerTimesProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF04100D), // Ultra Dark Emerald base
        body: Stack(
          children: [
            // 1. New Deep Ambient Background with Breathing Animation
            RepaintBoundary(
              child: _buildPremiumBackground(),
            ),

            // 2. Main Content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_currentIndex),
                child: _buildBody(_currentIndex, context, prayerProvider,
                    userProvider, themeProvider, lang),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: AppColors.royalGold,
                unselectedItemColor: Colors.white.withValues(alpha: 0.4),
                showSelectedLabels: true,
                showUnselectedLabels: false,
                selectedLabelStyle: const TextStyle(
                  fontFamily: 'NotoKufiArabic',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                currentIndex: _currentIndex > 3 ? 0 : _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home_outlined),
                    activeIcon: const Icon(Icons.home_rounded),
                    label: AppStrings.get('dock_home', lang),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.menu_book_outlined),
                    activeIcon: const Icon(Icons.menu_book_rounded),
                    label: AppStrings.get('dock_quran', lang),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.fingerprint_rounded),
                    activeIcon: const Icon(Icons.fingerprint_rounded),
                    label: AppStrings.get('dock_tasbih', lang),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.settings_outlined),
                    activeIcon: const Icon(Icons.settings_rounded),
                    label: AppStrings.get('dock_settings', lang),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
      int index,
      BuildContext context,
      PrayerTimesProvider prayerProvider,
      UserProvider userProvider,
      ThemeProvider themeProvider,
      String lang) {
    switch (index) {
      case 0:
        return _buildHomeContent(context, prayerProvider, userProvider, lang);
      case 1:
        return const QuranIndexScreen();
      case 2:
        return const TasbeehScreen();
      case 3:
        return _buildSettingsContent(
            context, themeProvider, lang); // Passed themeProvider here
      default:
        return _buildHomeContent(context, prayerProvider, userProvider, lang);
    }
  }

  Widget _buildPremiumBackground() {
    return AnimatedBuilder(
        animation: _breathAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // Deep Emerald Base Gradient
              const _StaticBackgroundGradient(),

              // Large Decorative Islamic Pattern (Mockup Style)
              Positioned(
                top: -100,
                right: -100,
                child: Opacity(
                  opacity: 0.08,
                  child: Transform.rotate(
                    angle: 0.1,
                    child: Image.asset(
                      'assets/images/islamic_compass_pattern.png',
                      width: 900,
                      height: 900,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(),
                    ),
                  ),
                ),
              ),

              // Cinematic Ambient Glows (Emerald & Gold)
              Positioned(
                top: 0,
                right: 0,
                child: Transform.scale(
                  scale: _breathAnimation.value,
                  child: Container(
                    width: 600,
                    height: 600,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(
                              0x4010B981), // AppColors.accentEmerald with 0.25 alpha
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Subtle Gold particles / lighting (Simulated)
              Positioned(
                bottom: -50,
                left: -50,
                child: Transform.scale(
                  scale: 1.1 - (_breathAnimation.value * 0.1),
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(
                              0x14D4AF37), // AppColors.royalGold with 0.08 alpha
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  Widget _buildHomeContent(
      BuildContext context,
      PrayerTimesProvider prayerProvider,
      UserProvider userProvider,
      String lang) {
    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 150),
        children: [
          _buildAnimatedItem(_headerAnim, _buildMockupHeader(context, lang)),
          const SizedBox(height: 10),
          _buildAnimatedItem(
              _cardAnim, _buildGreetingSection(lang, userProvider.userName)),
          const SizedBox(height: 16),
          _buildAnimatedItem(_cardAnim, _buildInspirationCard(lang)),
          const SizedBox(height: 24),
          // row of 2 cards
          _buildAnimatedItem(
              _cardAnim,
              _buildTopDoubleSection(
                  context, prayerProvider, userProvider, lang)),
          const SizedBox(height: 20),
          // row of 3 cards (Set 1)
          _buildAnimatedItem(
              _gridAnim, _buildBottomTripleSection(context, lang)),
          const SizedBox(height: 12),
          // row of 3 cards (Set 2)
          _buildAnimatedItem(
              _gridAnim, _buildSecondaryTripleSection(context, lang)),
          const SizedBox(height: 12),
          // row of 3 cards (Set 3)
          _buildAnimatedItem(
              _gridAnim, _buildThirdTripleSection(context, lang)),
        ],
      ),
    );
  }

  Widget _buildMockupHeader(BuildContext context, String lang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 44), // Alignment spacer for notification icon
        Column(
          children: [
            Text(
              AppStrings.get('app_name', lang),
              style: const TextStyle(
                fontFamily: 'NotoKufiArabic',
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            Consumer<PrayerTimesProvider>(
              builder: (context, prayerProvider, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.royalGold, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      prayerProvider.locationName,
                      style: TextStyle(
                        fontFamily: 'NotoKufiArabic',
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Stack(
            children: [
              const Icon(Icons.notifications_none_rounded,
                  color: AppColors.royalGold, size: 24),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildGreetingSection(String lang, String userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userName.isNotEmpty
              ? '${AppStrings.get('greeting', lang)}, $userName'
              : AppStrings.get('greeting', lang),
          style: const TextStyle(
            color: AppColors.royalGold,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${AppStrings.get('today', lang)}: ${DateFormat('EEEE, d MMMM yyyy', lang).format(DateTime.now())}'
              .toWesternDigits(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInspirationCard(String lang) {
    return Consumer<InspirationProvider>(
      builder: (context, inspirationProvider, _) {
        final inspiration = inspirationProvider.dailyInspiration;
        return LuxuryGlassCard(
          padding: const EdgeInsets.all(20),
          gradient: AppColors.goldGlassBorderGradient, // Subtle golden shine
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.format_quote_rounded,
                      color: AppColors.royalGold, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.get('inspiration_of_the_day', lang),
                    style: const TextStyle(
                      color: AppColors.royalGold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                lang == 'ar' ? inspiration.arabicText : inspiration.englishText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: lang == 'ar' ? 'Amiri' : null,
                  color: Colors.white,
                  fontSize: lang == 'ar' ? 22 : 16,
                  height: 1.8,
                  fontWeight: lang == 'ar' ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                lang == 'ar'
                    ? '- ${inspiration.arabicSource} -'
                    : '- ${inspiration.englishSource} -',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopDoubleSection(
      BuildContext context,
      PrayerTimesProvider prayerProvider,
      UserProvider userProvider,
      String lang) {
    return SizedBox(
      height: 300,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: Prayer Times
          Expanded(
            flex: 11,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/prayer-times'),
              child: LuxuryGlassCard(
                gradient: AppColors.premiumEmeraldCardGradient,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('prayer_times', lang),
                      style: const TextStyle(
                        fontFamily: 'NotoKufiArabic',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      AppStrings.get('current_location', lang),
                      style: TextStyle(
                        fontFamily: 'NotoKufiArabic',
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: _buildPrayerList(prayerProvider, lang),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Right: Quran
          Expanded(
            flex: 9,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/quran'),
              child: LuxuryGlassCard(
                gradient: AppColors.premiumEmeraldCardGradient,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.get('quran', lang),
                      style: const TextStyle(
                        fontFamily: 'NotoKufiArabic',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    _buildPremiumIcon(Icons.menu_book_rounded, size: 74),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.royalGold.withValues(alpha: 0.25),
                            AppColors.royalGold.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.royalGold.withValues(alpha: 0.15)),
                      ),
                      child: const Text(
                        'Sura Al-Mulk',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'NotoKufiArabic',
                          color: AppColors.royalGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
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
      children: prayers.map((p) {
        final time = provider.timeForPrayer(p);
        final isActive = provider.nextPrayer == p;
        return _buildPrayerListItem(
          name: provider.getPrayerName(p, lang),
          time: time != null ? provider.formatTime(time) : '--:--',
          isActive: isActive,
        );
      }).toList(),
    );
  }

  Widget _buildPrayerListItem(
      {required String name, required String time, required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isActive ? AppColors.royalGold : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.white60,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
          Text(
            time.toWesternDigits(),
            style: TextStyle(
              color: isActive ? Colors.black : Colors.white,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTripleSection(BuildContext context, String lang) {
    return Row(
      children: [
        Expanded(
            child: _buildSmallFeatureCard(
                AppStrings.get('azkar', lang), 'Adhkar', Icons.adjust_rounded,
                onTap: () {
          Navigator.pushNamed(context, '/azkar');
        })),
        const SizedBox(width: 12),
        Expanded(
            child: _buildSmallFeatureCard(
                AppStrings.get('qibla', lang), 'Qibla', Icons.explore_rounded,
                onTap: () {
          Navigator.pushNamed(context, '/qibla');
        })),
        const SizedBox(width: 12),
        Expanded(
            child: _buildSmallFeatureCard(AppStrings.get('faith_journey', lang),
                'Events', Icons.event_note_rounded, onTap: () {
          Navigator.pushNamed(context, '/faith-tracker');
        })),
      ],
    );
  }

  Widget _buildSecondaryTripleSection(BuildContext context, String lang) {
    return Row(
      children: [
        Expanded(
            child: _buildSmallFeatureCard(
                AppStrings.get('quiz_title', lang), 'Quiz', Icons.quiz_rounded,
                onTap: () {
          Navigator.pushNamed(context, '/quiz');
        })),
        const SizedBox(width: 12),
        Expanded(
            child: _buildSmallFeatureCard(
                AppStrings.get('names_of_allah', lang),
                '99 Names',
                Icons.auto_awesome_rounded, onTap: () {
          Navigator.pushNamed(context, '/names');
        })),
        const SizedBox(width: 12),
        Expanded(
            child: _buildSmallFeatureCard(
                AppStrings.get('stories_of_prophets', lang),
                'Stories',
                Icons.auto_stories_rounded, onTap: () {
          Navigator.pushNamed(context, '/stories');
        })),
      ],
    );
  }

  Widget _buildThirdTripleSection(BuildContext context, String lang) {
    return Row(
      children: [
        Expanded(
            child: _buildSmallFeatureCard(
                AppStrings.get('missed_prayers', lang),
                'Qada',
                Icons.history_rounded, onTap: () {
          Navigator.pushNamed(context, '/missed_prayers');
        })),
        const SizedBox(width: 12),
        Expanded(
            child: _buildSmallFeatureCard(AppStrings.get('khatma', lang),
                'Khatma', Icons.import_contacts_rounded, onTap: () {
          Navigator.pushNamed(context, '/khatma');
        })),
        const SizedBox(width: 12),
        Expanded(
            child: _buildSmallFeatureCard(AppStrings.get('mood_compass', lang),
                'Soul', Icons.self_improvement_rounded, onTap: () {
          Navigator.pushNamed(context, '/mood-guide');
        })),
      ],
    );
  }

  Widget _buildSmallFeatureCard(String title, String subtitle, IconData icon,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: LuxuryGlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPremiumIcon(icon, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'NotoKufiArabic',
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NotoKufiArabic',
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumIcon(IconData icon, {double size = 32}) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return AppColors.goldGradient.createShader(bounds);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle glow shadow behind
          Icon(
            icon,
            size: size + 2,
            color: Colors.black.withValues(alpha: 0.2),
          ),
          Icon(
            icon,
            size: size,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedItem(Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(animation),
        child: child,
      ),
    );
  }

  Widget _buildSettingsContent(
      BuildContext context, ThemeProvider themeProvider, String lang) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        _buildSettingsHeader(AppStrings.get('premium_settings', lang)),
        const SizedBox(height: 24),

        // Theme Section
        _buildSettingsSection(
          title: AppStrings.get('theme_dark_mode', lang),
          children: [
            _buildSettingsTile(
              icon: Icons.brightness_auto_rounded,
              title: AppStrings.get('theme_system', lang),
              trailing: themeProvider.themeMode == ThemeMode.system
                  ? const Icon(Icons.check_circle, color: AppColors.royalGold)
                  : null,
              onTap: () => themeProvider.setThemeMode(ThemeMode.system),
            ),
            const Divider(color: Colors.white10),
            _buildSettingsTile(
              icon: Icons.light_mode_rounded,
              title: AppStrings.get('theme_light', lang),
              trailing: themeProvider.themeMode == ThemeMode.light
                  ? const Icon(Icons.check_circle, color: AppColors.royalGold)
                  : null,
              onTap: () => themeProvider.setThemeMode(ThemeMode.light),
            ),
            const Divider(color: Colors.white10),
            _buildSettingsTile(
              icon: Icons.dark_mode_rounded,
              title: AppStrings.get('theme_dark', lang),
              trailing: themeProvider.themeMode == ThemeMode.dark
                  ? const Icon(Icons.check_circle, color: AppColors.royalGold)
                  : null,
              onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
            ),
          ],
        ),
        // Language Section
        _buildSettingsSection(
          title: AppStrings.get('language', lang),
          children: [
            _buildSettingsTile(
              icon: Icons.language_rounded,
              title: AppStrings.get('language_arabic', lang),
              trailing: lang == 'ar'
                  ? const Icon(Icons.check_circle, color: AppColors.royalGold)
                  : null,
              onTap: () => Provider.of<LocaleProvider>(context, listen: false)
                  .changeLocale(const Locale('ar')),
            ),
            const Divider(color: Colors.white10),
            _buildSettingsTile(
              icon: Icons.translate_rounded,
              title: AppStrings.get('language_english', lang),
              trailing: lang == 'en'
                  ? const Icon(Icons.check_circle, color: AppColors.royalGold)
                  : null,
              onTap: () => Provider.of<LocaleProvider>(context, listen: false)
                  .changeLocale(const Locale('en')),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Quiz Progress Section
        _buildSettingsSection(
          title: AppStrings.get('quiz_progress', lang),
          children: [
            _buildSettingsTile(
              icon: Icons.refresh_rounded,
              title: AppStrings.get('reset_seen_questions', lang),
              subtitle: AppStrings.get('reset_start_fresh', lang),
              onTap: () => _showResetQuizDialog(context, lang),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Navigation Section
        _buildSettingsSection(
          title: AppStrings.get('notifications_title', lang),
          children: [
            _buildSettingsTile(
              icon: Icons.notifications_active_rounded,
              title: AppStrings.get('adhan_settings', lang),
              onTap: () => Navigator.pushNamed(context, '/adhan-settings'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // About Section
        _buildSettingsSection(
          title: AppStrings.get('about_app', lang),
          children: [
            _buildSettingsTile(
              icon: Icons.info_outline_rounded,
              title: AppStrings.get('version_title', lang),
              trailing: Text(
                  '2.0.26 ${AppStrings.get('premium_version', lang)}'
                      .toWesternDigits(),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12)),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 100), // Space for floating dock
      ],
    );
  }

  Widget _buildSettingsHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            fontFamily: 'NotoKufiArabic',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12, right: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: AppColors.royalGold.withValues(alpha: 0.15),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        LuxuryGlassCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.royalGold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.royalGold, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'NotoKufiArabic',
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            )
          : null,
      trailing: trailing ??
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white10, size: 14),
    );
  }

  void _showResetQuizDialog(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1F16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Colors.white10)),
        title: Text(
          AppStrings.get('reset_questions', lang),
          style: const TextStyle(
              color: Colors.white, fontFamily: 'NotoKufiArabic'),
        ),
        content: Text(
          AppStrings.get('reset_confirm_msg', lang),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('cancel', lang),
                style: const TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<QuizProvider>(context, listen: false)
                  .resetPersistentProgress();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.get('reset_success_msg', lang)),
                  backgroundColor: AppColors.primaryEmerald,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(AppStrings.get('confirm', lang),
                style: const TextStyle(
                    color: AppColors.royalGold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _StaticBackgroundGradient extends StatelessWidget {
  const _StaticBackgroundGradient();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.premiumEmeraldBackgroundGradient,
      ),
    );
  }
}

class _AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedScaleButton({required this.child, required this.onTap});

  @override
  State<_AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<_AnimatedScaleButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
