import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  // Official Makkah Live Stream (often changes, but this is a standard search endpoint or common ID)
  // For production, a backend service should provide the active video IDs.
  final String _makkahVideoId = 'tSP2O-qQatU';
  final String _madinahVideoId = 'w8kQigG8DTE';

  late YoutubePlayerController _makkahController;
  late YoutubePlayerController _madinahController;

  @override
  void initState() {
    super.initState();
    _makkahController = YoutubePlayerController(
      initialVideoId: _makkahVideoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        isLive: true,
      ),
    );
    _madinahController = YoutubePlayerController(
      initialVideoId: _madinahVideoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        isLive: true,
      ),
    );
  }

  @override
  void deactivate() {
    _makkahController.pause();
    _madinahController.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _makkahController.dispose();
    _madinahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          AppStrings.get('live_stream', lang),
          style: const TextStyle(
            color: AppColors.royalGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.royalGold),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStreamCard(
            context,
            lang: lang,
            titleKey: 'live_makkah',
            controller: _makkahController,
          ),
          const SizedBox(height: 24),
          _buildStreamCard(
            context,
            lang: lang,
            titleKey: 'live_madinah',
            controller: _madinahController,
          ),
        ],
      ),
    );
  }

  Widget _buildStreamCard(
    BuildContext context, {
    required String lang,
    required String titleKey,
    required YoutubePlayerController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.royalGold.withValues(alpha: 0.3), width: 1),
        gradient: AppColors.premiumEmeraldBackgroundGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.emergency_recording_rounded,
                    color: Colors.redAccent),
                const SizedBox(width: 12),
                Text(
                  AppStrings.get(titleKey, lang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: YoutubePlayer(
              controller: controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.royalGold,
              progressColors: const ProgressBarColors(
                playedColor: AppColors.royalGold,
                handleColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
