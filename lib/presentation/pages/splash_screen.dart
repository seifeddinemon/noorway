import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  final bool navigateHome;
  const SplashScreen({super.key, this.navigateHome = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    _mainController.forward();

    // Performance: Pre-cache major assets while splash is showing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheAssets();
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          widget.navigateHome ? '/home' : '/onboarding',
        );
      }
    });
  }

  void _precacheAssets() {
    final images = [
      'assets/images/logo_noorfaith.png',
      'assets/images/ob_azkar.png',
      'assets/images/ob_prayer.png',
      'assets/images/ob_names.png',
      'assets/images/islamic_compass_pattern.png',
    ];

    for (var imagePath in images) {
      precacheImage(AssetImage(imagePath), context).catchError((e) {
        debugPrint('Pre-cache error for $imagePath: $e');
      });
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.primaryEmerald,
      body: Stack(
        children: [
          // 1. Premium Brand Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.premiumEmeraldBackgroundGradient,
              ),
            ),
          ),

          // 2. Sophisticated Vignette & Pattern
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          Opacity(
            opacity: 0.05,
            child: Image.asset(
              'assets/patterns/islamic_pattern.png',
              repeat: ImageRepeat.repeat,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(),
            ),
          ),

          // 3. Central Branding
          Center(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Pulsing Logo Glow
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.royalGold.withValues(
                                        alpha: _glowAnimation.value),
                                    blurRadius: 100,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: child,
                            );
                          },
                          child: Hero(
                            tag: 'app_logo',
                            child: Image.asset(
                              'assets/images/logo_noorfaith.png',
                              width: 180,
                              height: 180,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.mosque_rounded,
                                      size: 100, color: AppColors.royalGold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // App Name with luxury typography
                        Text(
                          AppStrings.get('app_name', lang),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'NotoKufiArabic',
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: AppColors.royalGold,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Glassmorphic Slogan Container
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withValues(alpha: 0.05),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Text(
                            AppStrings.get('glow_text', lang).toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'NotoKufiArabic',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 4,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 4. Loading indicator at the bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: AppColors.royalGold,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
