import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;

    final List<Map<String, dynamic>> pages = [
      {
        'title': AppStrings.get('onboarding_1_title', lang),
        'desc': AppStrings.get('onboarding_1_desc', lang),
        'image': 'assets/images/ob_azkar.png',
      },
      {
        'title': AppStrings.get('onboarding_2_title', lang),
        'desc': AppStrings.get('onboarding_2_desc', lang),
        'image': 'assets/images/ob_prayer.png',
      },
      {
        'title': AppStrings.get('ob_location_title', lang),
        'desc': AppStrings.get('ob_location_desc', lang),
        'image': 'assets/images/ob_prayer.png',
        'isPermission': true,
      },
      {
        'title': AppStrings.get('onboarding_3_title', lang),
        'desc': AppStrings.get('onboarding_3_desc', lang),
        'image': 'assets/images/ob_names.png',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF04100D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.premiumEmeraldGradient,
        ),
        child: Stack(
          children: [
            // Immersive background pattern
            Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/islamic_compass_pattern.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top Section: Skip Button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Hero(
                          tag: 'app_logo',
                          child: Image.asset(
                            'assets/images/logo_noorfaith.png',
                            width: 60,
                            height: 60,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.mosque,
                                    size: 30, color: AppColors.royalGold),
                          ),
                        ),
                        TextButton(
                          onPressed: _completeOnboarding,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.royalGold,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                  color: AppColors.royalGold
                                      .withValues(alpha: 0.15)),
                            ),
                          ),
                          child: Text(
                            AppStrings.get('skip', lang),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Middle Section: PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Image with Premium Container
                                Container(
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.15),
                                        blurRadius: 40,
                                        offset: const Offset(0, 20),
                                      ),
                                      BoxShadow(
                                        color: AppColors.royalGold
                                            .withValues(alpha: 0.15),
                                        blurRadius: 60,
                                        spreadRadius: -10,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      pages[index]['image'] as String,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: AppColors.royalGold
                                            .withValues(alpha: 0.15),
                                        child: const Icon(Icons.image,
                                            size: 50,
                                            color: AppColors.royalGold),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 60),
                                // Content Card
                                Text(
                                  pages[index]['title'] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'NotoKufiArabic',
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.royalGold,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  pages[index]['desc'] as String,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    height: 1.6,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom Section: Navigation
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Indicator
                        Row(
                          children: List.generate(
                            pages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 32 : 12,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? AppColors.royalGold
                                    : Colors.white24,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),

                        // Next Button
                        GestureDetector(
                          onTap: () async {
                            if (pages[_currentPage]
                                .containsKey('isPermission')) {
                              final status =
                                  await Geolocator.requestPermission();
                              if (status == LocationPermission.denied ||
                                  status == LocationPermission.deniedForever) {
                                // Optionally show a dialog, but for now we just move next if they click
                              }
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOutQuint,
                              );
                              return;
                            }

                            if (_currentPage == pages.length - 1) {
                              _completeOnboarding();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOutQuint,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.goldGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.royalGold
                                      .withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _currentPage == pages.length - 1
                                  ? Icons.check_rounded
                                  : (pages[_currentPage]
                                          .containsKey('isPermission')
                                      ? Icons.location_on_rounded
                                      : Icons.arrow_forward_ios_rounded),
                              color: AppColors.primaryEmerald,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
