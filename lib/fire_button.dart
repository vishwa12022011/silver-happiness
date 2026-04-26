// ─────────────────────────────────────────────
//  fire_button.dart
//  Large circular fire button with press animation
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'valorant_theme.dart';

class FireButton extends StatefulWidget {
  final String elementId;
  final bool isLeft;   // true = ADS/left fire button
  final double baseSize;
  const FireButton({super.key, required this.elementId, this.isLeft = false, this.baseSize = 72});

  @override
  State<FireButton> createState() => _FireButtonState();
}

class _FireButtonState extends State<FireButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _down(_) { setState(() => _pressed = true);  _ctrl.forward(); }
  void _up(_)   { setState(() => _pressed = false); _ctrl.reverse(); }

  @override
  Widget build(BuildContext context) {
    final size   = widget.baseSize;
    final accent = widget.isLeft ? VColors.teal : VColors.red;
    final icon   = widget.isLeft ? Icons.center_focus_strong : Icons.gps_fixed;

    return GestureDetector(
      onTapDown:   _down,
      onTapUp:     _up,
      onTapCancel: () { setState(() => _pressed = false); _ctrl.reverse(); },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              _pressed ? accent.withOpacity(0.55) : accent.withOpacity(0.22),
              Colors.black.withOpacity(0.70),
            ]),
            border: Border.all(color: accent.withOpacity(_pressed ? 1.0 : 0.80), width: 2.2),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(_pressed ? 0.65 : 0.30),
                blurRadius: _pressed ? 20 : 10,
                spreadRadius: _pressed ? 4 : 1,
              ),
            ],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white, size: size * 0.32),
            const SizedBox(height: 3),
            Text(
              widget.isLeft ? 'ADS' : 'FIRE',
              style: VTheme.label(size: 8.5, color: Colors.white),
            ),
          ]),
        ),
      ),
    );
  }
}
