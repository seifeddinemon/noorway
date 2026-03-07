import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_theme.dart';
import 'core/theme_provider.dart';
import 'core/locale_provider.dart';
import 'core/user_provider.dart';
import 'core/favorites_provider.dart';
import 'core/hadith_provider.dart';
import 'core/last_reading_provider.dart';
import 'core/prayer_times_provider.dart';
import 'core/stories_provider.dart';
import 'core/quiz_provider.dart';
import 'core/adhan_settings_provider.dart';
import 'features/azkar/azkar_categories_screen.dart';
import 'features/azkar/favorites_screen.dart';
import 'features/names/names_screen.dart';
import 'features/prayer_times/prayer_times_screen.dart';
import 'features/qibla/qibla_screen.dart';
import 'features/quran/quran_index_screen.dart';
import 'features/tasbeeh/tasbeeh_screen.dart';
import 'features/stories/stories_screen.dart';
import 'features/stories/story_detail_screen.dart';
import 'features/quiz/quiz_screen.dart';
import 'features/hadiths/hadiths_screen.dart';
import 'features/adhan/adhan_settings_screen.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/pages/onboarding_screen.dart';
import 'presentation/pages/premium_dashboard_screen.dart';
import 'features/faith/faith_tracker_screen.dart';
import 'features/soul/mood_guide_screen.dart';
import 'core/faith_tracker_provider.dart';
import 'core/khatma_provider.dart';
import 'core/missed_prayers_provider.dart';
import 'core/inspiration_provider.dart';
import 'features/faith/missed_prayers_screen.dart';
import 'services/local_notification_service.dart';
import 'services/adhan_scheduler.dart';

void main() async {
  // Capture Flutter Framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  // Show a custom error screen instead of a white screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: const Color(0xFF04100D),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Color(0xFFD4AF37), size: 64),
            const SizedBox(height: 16),
            const Text(
              'Error loading app', // Safe English fallback
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              details.exception.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  };

  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Catch errors during date initialization
    try {
      await initializeDateFormatting('ar', null);
      await initializeDateFormatting('en', null);
    } catch (e) {
      debugPrint('Date initialization error: $e');
    }

    Intl.defaultLocale = 'ar';

    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    runApp(NoorWayApp(showOnboarding: !seenOnboarding));

    // Initialize background services
    Future.microtask(() async {
      try {
        final notificationService = LocalNotificationService();
        await notificationService.init();
        await notificationService.requestNotificationPermission();
        await notificationService.requestExactAlarmsPermission();
        await notificationService.requestBatteryOptimizationExemption();
        await AdhanScheduler.scheduleNextPrayers();
      } catch (e) {
        debugPrint('Post-startup service error: $e');
      }
    });
  } catch (e, stack) {
    debugPrint('FATAL CRASH IN MAIN: $e');
    debugPrint(stack.toString());
    // Try to run the app even if initialization fails partially
    runApp(const NoorWayApp(showOnboarding: true));
  }
}

class NoorWayApp extends StatelessWidget {
  final bool showOnboarding;

  const NoorWayApp({super.key, this.showOnboarding = false});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => LastReadingProvider()),
        ChangeNotifierProvider(create: (_) => PrayerTimesProvider()),
        ChangeNotifierProvider(create: (_) => StoriesProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
            create: (_) => HadithProvider()), // Added HadithProvider
        ChangeNotifierProvider(create: (_) => AdhanSettingsProvider()),
        ChangeNotifierProvider(create: (_) => FaithTrackerProvider()),
        ChangeNotifierProvider(create: (_) => KhatmaProvider()),
        ChangeNotifierProvider(create: (_) => MissedPrayersProvider()),
        ChangeNotifierProvider(create: (_) => InspirationProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'NoorFaith',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            initialRoute: '/splash',
            routes: {
              '/splash': (context) =>
                  SplashScreen(navigateHome: !showOnboarding),
              '/onboarding': (context) => const OnboardingScreen(),
              '/home': (context) => const PremiumDashboardScreen(),
              '/azkar': (context) => const AzkarCategoriesScreen(),
              '/favorites': (context) => const FavoritesScreen(),
              '/names': (context) => const NamesScreen(),
              '/prayer-times': (context) => const PrayerTimesScreen(),
              '/qibla': (context) => const QiblaScreen(),
              '/quran': (context) => const QuranIndexScreen(),
              '/tasbeeh': (context) => const TasbeehScreen(),
              '/stories': (context) => const StoriesScreen(),
              '/story_detail': (context) => const StoryDetailScreen(),
              '/quiz': (context) => const QuizScreen(),
              '/hadiths': (context) => const HadithsScreen(),
              '/adhan-settings': (context) => const AdhanSettingsScreen(),
              '/faith-tracker': (context) => const FaithTrackerScreen(),
              '/mood-guide': (context) => const MoodGuideScreen(),
              '/premium-dashboard': (context) => const PremiumDashboardScreen(),
              '/khatma': (context) => const QuranIndexScreen(),
              '/missed_prayers': (context) => const MissedPrayersScreen(),
            },
          );
        },
      ),
    );
  }
}
