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

class _QiblaScreenState extends State<QiblaScreen> {
  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();
  bool? _sensorSupported;

  // For fallback (no compass sensor)
  bool _isLoadingFallback = false;
  double? _fallbackBearing;
  String? _fallbackError;

  // For waiting timeout
  bool _isWaitingTooLong = false;
  Timer? _waitingTimer;

  @override
  void initState() {
    super.initState();
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    _sensorSupported = await FlutterQiblah.androidDeviceSensorSupport();
    if (mounted) {
      setState(() {});
    }

    if (_sensorSupported == true) {
      _checkLocationStatus();
    } else if (_sensorSupported == false) {
      _loadStaticQibla();
    }
  }

  Future<void> _loadStaticQibla() async {
    setState(() {
      _isLoadingFallback = true;
      _fallbackError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("location_disabled");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("location_denied");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("location_denied");
      }

      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );

      _fallbackBearing = _calculateQibla(position.latitude, position.longitude);
    } catch (e) {
      _fallbackError = e.toString().contains('location')
          ? e.toString().replaceAll('Exception: ', '')
          : 'location_error';
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFallback = false;
        });
      }
    }
  }

  double _calculateQibla(double lat, double lng) {
    const double meccaLat = 21.422487;
    const double meccaLng = 39.826206;

    double lat1 = lat * math.pi / 180.0;
    double lng1 = lng * math.pi / 180.0;
    double lat2 = meccaLat * math.pi / 180.0;
    double lng2 = meccaLng * math.pi / 180.0;

    double dLon = lng2 - lng1;

    double y = math.sin(dLon) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double brng = math.atan2(y, x);
    brng = (brng * 180.0 / math.pi + 360.0) % 360.0;
    return brng;
  }

  @override
  void dispose() {
    _locationStreamController.close();
    _waitingTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkLocationStatus() async {
    final status = await FlutterQiblah.checkLocationStatus();
    if (status.enabled &&
        (status.status == LocationPermission.denied ||
            status.status == LocationPermission.deniedForever)) {
      try {
        await FlutterQiblah.requestPermissions();
        final updatedStatus = await FlutterQiblah.checkLocationStatus();
        _locationStreamController.sink.add(updatedStatus);
      } catch (e) {
        _locationStreamController.sink.add(status);
      }
    } else {
      _locationStreamController.sink.add(status);
    }
  }

  void _startWaitingTimer() {
    _waitingTimer?.cancel();
    _isWaitingTooLong = false;
    _waitingTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isWaitingTooLong = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;

    if (_sensorSupported == null) {
      return LuxuryScaffold(
        title: AppStrings.get('qibla', lang),
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.royalGold)),
      );
    }

    if (_sensorSupported == false) {
      return LuxuryScaffold(
        title: AppStrings.get('qibla', lang),
        body: _buildNoCompassFallback(lang),
      );
    }

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
          if (snapshot.data!.status == LocationPermission.denied ||
              snapshot.data!.status == LocationPermission.deniedForever) {
            return _buildErrorWidget(
                AppStrings.get('location_denied', lang), Icons.gpp_bad_rounded);
          }

          return StreamBuilder<QiblahDirection>(
            stream: FlutterQiblah.qiblahStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                if (_waitingTimer == null ||
                    !_waitingTimer!.isActive && !_isWaitingTooLong) {
                  _startWaitingTimer();
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                          color: AppColors.royalGold),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                            _isWaitingTooLong
                                ? (lang == 'ar'
                                    ? 'جاري البحث عن GPS والبوصلة... يرجى معايرة البوصلة بتحريك الهاتف على شكل 8، والاقتراب من النافذة.'
                                    : 'Searching for GPS & Compass... Please calibrate by moving phone in figure 8, and move near a window.')
                                : AppStrings.get('waiting_for_gps', lang),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.5)),
                      ),
                    ],
                  ),
                );
              }

              _waitingTimer?.cancel();
              _isWaitingTooLong = false;

              if (snapshot.hasError) {
                return _buildErrorWidget(AppStrings.get('location_error', lang),
                    Icons.error_outline_rounded);
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

  Widget _buildNoCompassFallback(String lang) {
    if (_isLoadingFallback) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.royalGold),
          const SizedBox(height: 24),
          Text(lang == 'ar' ? 'جاري تحديد الموقع...' : 'Getting Location...',
              style: const TextStyle(color: Colors.white70)),
        ],
      ));
    }

    if (_fallbackError != null) {
      String msg = AppStrings.get('location_error', lang);
      if (_fallbackError == 'location_disabled') {
        msg = AppStrings.get('location_disabled', lang);
      }
      if (_fallbackError == 'location_denied') {
        msg = AppStrings.get('location_denied', lang);
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildErrorWidget(msg, Icons.location_off_rounded),
          const SizedBox(height: 16),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.royalGold),
            onPressed: _loadStaticQibla,
            child: Text(lang == 'ar' ? 'إعادة المحاولة' : 'Retry',
                style: const TextStyle(color: Colors.black)),
          )
        ],
      );
    }

    if (_fallbackBearing != null) {
      String compassStr = _getCompassDirection(_fallbackBearing!, lang);
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.explore_off_rounded,
                  size: 64, color: Colors.white30),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  lang == 'ar'
                      ? 'جهازك لا يحتوي على مستشعر البوصلة لتحريك الإبرة، ولكن قمنا بحساب الاتجاه لك:'
                      : 'Your device does not support a compass sensor, but we calculated the Qibla direction for you:',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 16, height: 1.5),
                ),
              ),
              const SizedBox(height: 32),
              LuxuryGlassCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text(
                      lang == 'ar'
                          ? 'اتجاه القبلة من موقعك هو:'
                          : 'Qibla direction from your location is:',
                      style: const TextStyle(
                          color: AppColors.royalGold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${_fallbackBearing!.toStringAsFixed(1)}°',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      compassStr,
                      style: const TextStyle(
                          color: AppColors.royalGold,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  lang == 'ar'
                      ? 'يمكنك استخدام شروق الشمس أو بوصلة حقيقية لمعرفة هذا الاتجاه بدقة.'
                      : 'You can use sunrise or a physical compass to find this precise direction.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container();
  }

  String _getCompassDirection(double bearing, String lang) {
    if (lang == 'ar') {
      if (bearing >= 337.5 || bearing < 22.5) return 'الشمال';
      if (bearing >= 22.5 && bearing < 67.5) return 'الشمال الشرقي';
      if (bearing >= 67.5 && bearing < 112.5) return 'الشرق';
      if (bearing >= 112.5 && bearing < 157.5) return 'الجنوب الشرقي';
      if (bearing >= 157.5 && bearing < 202.5) return 'الجنوب';
      if (bearing >= 202.5 && bearing < 247.5) return 'الجنوب الغربي';
      if (bearing >= 247.5 && bearing < 292.5) return 'الغرب';
      return 'الشمال الغربي';
    } else {
      if (bearing >= 337.5 || bearing < 22.5) return 'North';
      if (bearing >= 22.5 && bearing < 67.5) return 'North-East';
      if (bearing >= 67.5 && bearing < 112.5) return 'East';
      if (bearing >= 112.5 && bearing < 157.5) return 'South-East';
      if (bearing >= 157.5 && bearing < 202.5) return 'South';
      if (bearing >= 202.5 && bearing < 247.5) return 'South-West';
      if (bearing >= 247.5 && bearing < 292.5) return 'West';
      return 'North-West';
    }
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
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon,
            size: 64, color: AppColors.royalGold.withValues(alpha: 0.15)),
        const SizedBox(height: 16),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16))
      ]),
    ));
  }
}
