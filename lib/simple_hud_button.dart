// ─────────────────────────────────────────────
//  simple_hud_button.dart
//  Convenience wrapper: icon + label inside HudButton
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'hud_button.dart';
import 'valorant_theme.dart';

class SimpleHudButton extends StatelessWidget {
  final String elementId;
  final IconData icon;
  final String label;
  final double iconSize;
  final double baseSize;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color accentColor;
  final bool circular;

  const SimpleHudButton({
    super.key,
    required this.elementId,
    required this.icon,
    required this.label,
    this.iconSize = 18,
    this.baseSize = 46,
    this.onTap,
    this.onLongPress,
    this.accentColor = VColors.red,
    this.circular = false,
  });

  @override
  Widget build(BuildContext context) {
    return HudButton(
      elementId: elementId,
      baseSize: baseSize,
      onTap: onTap,
      onLongPress: onLongPress,
      accentColor: accentColor,
      circular: circular,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: VColors.white, size: iconSize),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 1),
            Text(label, style: VTheme.label(size: 7), textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
