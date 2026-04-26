// ─────────────────────────────────────────────
//  hud_joystick.dart
//  Free Fire–style joystick with sprint detection
// ─────────────────────────────────────────────

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'hud_config.dart';
import 'hud_provider.dart';
import 'valorant_theme.dart';

class HudJoystick extends StatefulWidget {
  final double baseRadius;
  final double knobRadius;

  const HudJoystick({super.key, this.baseRadius = 62, this.knobRadius = 25});

  @override
  State<HudJoystick> createState() => _HudJoystickState();
}

class _HudJoystickState extends State<HudJoystick> {
  Offset _knob = Offset.zero;
  Offset? _origin;
  bool _active = false;

  // ── Gesture callbacks ────────────────────────
  void _start(DragStartDetails d) {
    setState(() {
      _active = true;
      _origin = d.localPosition;
      _knob = Offset.zero;
    });
    context.read<HudProvider>().setSprintMode(SprintMode.walk);
  }

  void _update(DragUpdateDetails d) {
    if (_origin == null) return;
    final raw  = d.localPosition - _origin!;
    final dist = raw.distance;
    final maxR = widget.baseRadius - widget.knobRadius;
    final clamped = dist > maxR ? raw / dist * maxR : raw;
    setState(() => _knob = clamped);

    final provider = context.read<HudProvider>();
    if (raw.dy < -(widget.baseRadius * 0.55)) {
      provider.setSprintMode(SprintMode.sprint);
    } else if (dist > 6) {
      provider.setSprintMode(SprintMode.walk);
    } else {
      provider.setSprintMode(SprintMode.none);
    }
  }

  void _end(DragEndDetails _) {
    setState(() {
      _active = false;
      _knob   = Offset.zero;
      _origin = null;
    });
    context.read<HudProvider>().setSprintMode(SprintMode.none);
  }

  // ── Build ────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sprinting = context.watch<HudProvider>().sprintMode == SprintMode.sprint;
    final R = widget.baseRadius;
    final k = widget.knobRadius;
    final D = R * 2;

    return GestureDetector(
      onPanStart:  _start,
      onPanUpdate: _update,
      onPanEnd:    _end,
      child: SizedBox(
        width: D, height: D,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Outer ring ──────────────────────
            _Ring(radius: D, sprinting: sprinting, opacity: 0.38, borderWidth: 1.6),
            // ── Inner guide ring ────────────────
            _Ring(radius: R, sprinting: false, opacity: 0.15, borderWidth: 0.8),
            // ── Cardinal ticks ──────────────────
            for (final a in [0.0, pi / 2, pi, 3 * pi / 2])
              Transform.translate(
                offset: Offset(cos(a) * (R - 9), sin(a) * (R - 9)),
                child: Container(
                  width: 4, height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: VColors.white.withOpacity(0.35),
                  ),
                ),
              ),
            // ── Knob ────────────────────────────
            Transform.translate(
              offset: _knob,
              child: Container(
                width: k * 2, height: k * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    sprinting ? VColors.red.withOpacity(0.95) : VColors.white.withOpacity(0.90),
                    sprinting ? VColors.darkRed.withOpacity(0.70) : VColors.offWhite.withOpacity(0.50),
                  ]),
                  border: Border.all(
                    color: sprinting ? VColors.red : VColors.white.withOpacity(0.60),
                    width: 1.5,
                  ),
                  boxShadow: [BoxShadow(
                    color: (sprinting ? VColors.red : VColors.white).withOpacity(0.30),
                    blurRadius: 9,
                  )],
                ),
                child: Center(
                  child: Icon(
                    sprinting ? Icons.double_arrow : Icons.gamepad_rounded,
                    color: Colors.black54,
                    size: k * 0.68,
                  ),
                ),
              ),
            ),
            // ── Sprint badge ─────────────────────
            if (sprinting)
              Positioned(
                top: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: VColors.red.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text('SPRINT', style: VTheme.label(size: 7)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double radius;
  final bool sprinting;
  final double opacity;
  final double borderWidth;
  const _Ring({required this.radius, required this.sprinting, required this.opacity, required this.borderWidth});

  @override
  Widget build(BuildContext context) => Container(
        width: radius, height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.30),
          border: Border.all(
            color: sprinting ? VColors.red.withOpacity(0.9) : VColors.white.withOpacity(opacity),
            width: borderWidth,
          ),
          boxShadow: sprinting
              ? [BoxShadow(color: VColors.red.withOpacity(0.35), blurRadius: 12, spreadRadius: 2)]
              : [],
        ),
      );
}
