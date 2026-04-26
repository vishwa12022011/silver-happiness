// ─────────────────────────────────────────────
//  valorant_theme.dart
//  All colors, text styles & decoration helpers
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';

class VColors {
  VColors._();
  static const Color red       = Color(0xFFFF4655);
  static const Color darkRed   = Color(0xFFBD3944);
  static const Color white     = Color(0xFFECE8E1);
  static const Color offWhite  = Color(0xFFC4B99A);
  static const Color teal      = Color(0xFF00B4D8);
  static const Color cyan      = Color(0xFF0DCAF0);
  static const Color darkBg    = Color(0xFF0F1923);
  static const Color darkBg2   = Color(0xFF1A232D);
  static const Color panelBg   = Color(0xFF16202A);
  static const Color border    = Color(0xFF2C3540);
  static const Color gold      = Color(0xFFFFD700);
  static const Color green     = Color(0xFF50E3C2);
  static const Color abilityFg = Color(0xFF00FFD1);
  static const Color ultimateR = Color(0xFFFF4655);
}

class VTheme {
  VTheme._();

  // ── Text ─────────────────────────────────────
  static TextStyle label({
    double size = 9,
    Color color = VColors.white,
    FontWeight weight = FontWeight.w700,
  }) =>
      TextStyle(
        fontFamily: 'Roboto',
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: 1.1,
        shadows: const [Shadow(color: Colors.black87, blurRadius: 3, offset: Offset(0, 1))],
      );

  // ── Box decorations ──────────────────────────
  static BoxDecoration button({
    Color border = VColors.red,
    Color bg = const Color(0x99000000),
    double borderWidth = 1.5,
    double radius = 8,
  }) =>
      BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: borderWidth),
        boxShadow: [BoxShadow(color: border.withOpacity(0.28), blurRadius: 7, spreadRadius: 1)],
      );

  static BoxDecoration abilityBox({bool active = false, bool isUlt = false}) {
    final accent = isUlt ? VColors.ultimateR : VColors.abilityFg;
    return BoxDecoration(
      color: active ? accent.withOpacity(0.22) : Colors.black.withOpacity(0.62),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(
        color: active ? accent : VColors.offWhite.withOpacity(0.40),
        width: active ? 2.0 : 1.0,
      ),
      boxShadow: active
          ? [BoxShadow(color: accent.withOpacity(0.45), blurRadius: 12, spreadRadius: 2)]
          : [],
    );
  }

  static BoxDecoration weaponSlot({bool active = false, Color accent = VColors.red}) =>
      BoxDecoration(
        color: active ? accent.withOpacity(0.18) : Colors.black.withOpacity(0.58),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: active ? accent : VColors.border.withOpacity(0.65),
          width: active ? 1.8 : 1.0,
        ),
        boxShadow: active
            ? [BoxShadow(color: accent.withOpacity(0.32), blurRadius: 8, spreadRadius: 1)]
            : [],
      );

  // ── SliderThemeData factory ───────────────────
  static SliderThemeData sliderTheme(BuildContext ctx, {Color accent = VColors.red}) =>
      SliderTheme.of(ctx).copyWith(
        activeTrackColor: accent,
        thumbColor: VColors.white,
        inactiveTrackColor: VColors.border,
        overlayColor: accent.withOpacity(0.20),
        trackHeight: 2.5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      );
}
