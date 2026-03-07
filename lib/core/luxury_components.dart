import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class LuxuryScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? floatingActionButton;

  const LuxuryScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBackButton = true,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryEmerald,
      extendBodyBehindAppBar: true,
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        leading: (showBackButton && Navigator.of(context).canPop())
            ? _GlassBackButton()
            : null,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        actions: actions,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 0. Solid Base Layer (Safety for navigation transitions)
          Container(color: AppColors.primaryEmerald),

          // 1. Unified Luxury Background
          const RepaintBoundary(
            child: _UnifiedBackground(),
          ),

          // 2. Main Content
          SafeArea(child: body),
        ],
      ),
    );
  }
}

class _UnifiedBackground extends StatelessWidget {
  const _UnifiedBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solid Base Layer to prevent black screen artifacts during transitions
        Container(color: AppColors.primaryEmerald),
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.premiumRadialGradient,
          ),
        ),
        Opacity(
          opacity: 0.03,
          child: Image.asset(
            'assets/images/islamic_compass_pattern.png',
            repeat: ImageRepeat.repeat,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => Container(),
          ),
        ),
        // Subtle Ambient Glows
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.royalGold.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }
}

class LuxuryGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final BoxBorder? border;

  const LuxuryGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 28, // Increased for 2026 look
    this.blur = 30, // Increased for premium feel
    this.gradient,
    this.boxShadow,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: AppColors.deepEmeraldShadow,
                blurRadius: 40,
                offset: const Offset(0, 20),
                spreadRadius: -10,
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: gradient == null
                  ? Colors.white.withValues(alpha: 0.03)
                  : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: AppColors.glassGoldBorder, width: 0.8),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.royalGold,
          size: 16,
        ),
      ),
    );
  }
}

class LuxuryListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback onTap;

  const LuxuryListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: LuxuryGlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 16)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
