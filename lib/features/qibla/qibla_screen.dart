import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/luxury_components.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class __QiblaScreenState extends State<QiblaScreen> {
  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  @override
  void dispose() {
    _locationStreamController.close();
    super.dispose();
  }

  Future<void> _checkLocationStatus() async {
    final status = await FlutterQiblah.checkLocationStatus();
    if (status.enabled && status.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final updatedStatus = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(updatedStatus);
    } else {
      _locationStreamController.sink.add(status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;
    return LuxuryScaffold(
      title: AppStrings.get('qibla', lang),
      body: StreamBuilder<LocationStatus>(
        stream: _locationStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.royalGold));
          }
          if (snapshot.data == null || snapshot.data!.enabled == false) {
            return _buildErrorWidget(AppStrings.get('location_disabled', lang),
                Icons.location_off_rounded);
          }
          return StreamBuilder<QiblahDirection>(
            stream: FlutterQiblah.qiblahStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.royalGold));
              }
              final qiblaDirection = snapshot.data!;
              final bool isFacingQibla = qiblaDirection.offset.abs() < 5;

              if (isFacingQibla) {
                Vibration.vibrate(duration: 100);
              }

              return LayoutBuilder(builder: (context, constraints) {
                final double size =
                    math.min(constraints.maxWidth * 0.85, 340.0);
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildModernInfoCard(qiblaDirection, lang),
                      _buildUltraLuxuryCompass(
                          qiblaDirection, isFacingQibla, size),
                      _buildGuidanceModule(isFacingQibla, lang),
                    ],
                  ),
                );
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildModernInfoCard(QiblahDirection direction, String lang) {
    return LuxuryGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      borderRadius: 100, // Pill shaped for info card
      child: Text('${direction.offset.toStringAsFixed(1)}°',
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
    );
  }

  Widget _buildUltraLuxuryCompass(
      QiblahDirection direction, bool isFacing, double size) {
    final double needleSize = size * 0.65;
    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Compass Plate (Background)
        Image.asset(
          'assets/images/compass_plate_new.png',
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
          ),
        ),

        // 2. Rotating Needle with Smooth Animation and Effects
        TweenAnimationBuilder<double>(
          tween: Tween<double>(
              begin: 0, end: direction.qiblah * (math.pi / 180) * -1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, angle, child) {
            return Transform.rotate(
              angle: angle,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Needle Glow effect when facing Qibla
                  if (isFacing)
                    Container(
                      width: needleSize * 1.1,
                      height: needleSize * 1.1,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.royalGold.withValues(alpha: 0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),

                  // The New Premium Needle
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/qibla_needle.png',
                      width: needleSize,
                      height: needleSize,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.navigation_rounded,
                        color: AppColors.royalGold,
                        size: needleSize * 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // 3. Center Indicator (Mosque)
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF011A14).withValues(alpha: 0.8),
            border: Border.all(
                color: AppColors.royalGold.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.mosque_rounded,
              color: AppColors.royalGold, size: 24),
        ),
      ],
    );
  }

  Widget _buildGuidanceModule(bool isFacing, String lang) {
    return LuxuryGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Center(
        child: Text(
            isFacing
                ? AppStrings.get('facing_qibla', lang)
                : AppStrings.get('aim_at_qibla', lang),
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildErrorWidget(String message, IconData icon) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 64, color: AppColors.royalGold.withValues(alpha: 0.15)),
      const SizedBox(height: 16),
      Text(message, style: const TextStyle(color: Colors.white70))
    ]));
  }
}

class _QiblaScreenState extends __QiblaScreenState {}
