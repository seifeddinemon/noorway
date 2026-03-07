import 'package:flutter/material.dart';

class AppColors {
  // 2026 Premium Palette
  static const Color primaryEmerald = Color(0xFF011A14); // Deepest Emerald
  static const Color deepGradientGreen = Color(0xFF022C22); // Emerald 950
  static const Color accentEmerald = Color(0xFF064E3B); // Emerald 900

  static const Color royalGold = Color(0xFFD4AF37); // Premium Gold
  static const Color vibrantGold = Color(0xFFFFCC33); // Vibrant Highlight
  static const Color solidGoldHighlight =
      Color(0xFFC5A02E); // Solid darken gold for active states
  static const Color softGoldHighlight = Color(0xFFF3E5AB); // Soft Gold
  static const Color lightBackground = Color(0xFFF3F5F2);

  static const Color darkBackground = Color(0xFF011A14);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textGold = Color(0xFFD4AF37);
  static const Color textDark = Color(0xFF1F2937);

  // Glassmorphism & Effects
  static const Color glassWhite = Color(0x0DFFFFFF); // 5% White
  static const Color glassBorder = Color(0x14FFFFFF); // 8% White
  static const Color glassGoldBorder = Color(0x33D4AF37); // 20% Gold
  static const Color shadowColor = Color(0x80000000); // 50% Black
  static const Color deepEmeraldShadow = Color(0x66011A14); // 40% Deep Emerald
  static const Color goldGlow = Color(0x66D4AF37); // 40% Gold

  // High-End Gradients
  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF022C22), Color(0xFF064E3B)],
  );

  static const LinearGradient premiumEmeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF064E3B), // Emerald 900
      Color(0xFF011A14), // Deepest Emerald
    ],
  );

  static const RadialGradient premiumRadialGradient = RadialGradient(
    center: Alignment(0.0, -0.6),
    radius: 1.2,
    colors: [
      Color(0xFF064E3B), // Emerald 900 source
      Color(0xFF011A14), // Drowning into deep emerald
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [royalGold, vibrantGold, softGoldHighlight],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x26FFFFFF), // 15%
      Color(0x0AFFFFFF), // 4%
    ],
  );

  static const LinearGradient premiumEmeraldBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF032219), // Dark Emerald Top
      Color(0xFF011A14), // Deep Emerald Middle
      Color(0xFF000A08), // Near Black Bottom
    ],
  );

  static const LinearGradient premiumEmeraldCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF), // 20% White shine
      Color(0x0DFFFFFF), // 5% White base
    ],
  );

  static const LinearGradient goldGlassBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x4DD4AF37), // 30% Gold
      Color(0x1AD4AF37), // 10% Gold
      Color(0x4DD4AF37), // 30% Gold
    ],
  );
}
