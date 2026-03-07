import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  /// Wraps a widget with a subtle Islamic geometric pattern background.
  static Widget wrapWithBackgroundPattern(
      {required Widget child, double opacity = 0.1}) {
    return child;
  }

  /// Adds premium golden corner ornaments to a screen.
  static Widget addCornerOrnaments({required Widget child}) {
    return child;
  }

  /// Applies a glowing golden border decoration to a card or container.
  static BoxDecoration get premiumTileDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(
          color: AppColors.royalGold.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  /// Spiritual "Zena" overlay with ambient glows
  static Widget addSpiritualZena({required Widget child}) {
    return Stack(
      children: [
        // Ambient Spiritual Glows
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryEmerald.withValues(alpha: 0.1),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

