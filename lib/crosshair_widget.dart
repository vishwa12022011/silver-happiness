// ─────────────────────────────────────────────
//  crosshair_widget.dart
//  Custom-painted crosshair with 4 style modes
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'hud_config.dart';
import 'valorant_theme.dart';

class CrosshairWidget extends StatelessWidget {
  final CrosshairStyle style;
  final bool scoped;

  const CrosshairWidget({super.key, required this.style, this.scoped = false});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(64, 64),
        painter: _CrosshairPainter(style: style, scoped: scoped),
      );
}

class _CrosshairPainter extends CustomPainter {
  final CrosshairStyle style;
  final bool scoped;
  const _CrosshairPainter({required this.style, required this.scoped});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.80)
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    final line = Paint()
      ..color = VColors.white
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    final dot = Paint()
      ..color = VColors.white
      ..style = PaintingStyle.fill;

    switch (style) {
      case CrosshairStyle.valoCross:
        _valoCross(canvas, cx, cy, shadow, line, dot);
      case CrosshairStyle.cross:
        _cross(canvas, cx, cy, shadow, line);
      case CrosshairStyle.dot:
        _dot(canvas, cx, cy, shadow, dot);
      case CrosshairStyle.circle:
        _circle(canvas, cx, cy, shadow, line, dot);
    }

    if (scoped) _scopeOverlay(canvas, cx, cy);
  }

  void _valoCross(Canvas c, double cx, double cy, Paint sh, Paint ln, Paint dot) {
    const gap = 5.0, len = 10.0;
    for (final p in [sh, ln]) {
      c.drawLine(Offset(cx - gap - len, cy), Offset(cx - gap, cy), p);
      c.drawLine(Offset(cx + gap, cy),       Offset(cx + gap + len, cy), p);
      c.drawLine(Offset(cx, cy - gap - len), Offset(cx, cy - gap), p);
      c.drawLine(Offset(cx, cy + gap),       Offset(cx, cy + gap + len), p);
    }
    c.drawCircle(Offset(cx, cy), 1.6, Paint()..color = Colors.black87);
    c.drawCircle(Offset(cx, cy), 1.0, dot);
  }

  void _cross(Canvas c, double cx, double cy, Paint sh, Paint ln) {
    const h = 13.0;
    for (final p in [sh, ln]) {
      c.drawLine(Offset(cx - h, cy), Offset(cx + h, cy), p);
      c.drawLine(Offset(cx, cy - h), Offset(cx, cy + h), p);
    }
  }

  void _dot(Canvas c, double cx, double cy, Paint sh, Paint dot) {
    c.drawCircle(Offset(cx, cy), 3.5, sh..style = PaintingStyle.fill);
    c.drawCircle(Offset(cx, cy), 2.0, dot);
  }

  void _circle(Canvas c, double cx, double cy, Paint sh, Paint ln, Paint dot) {
    c.drawCircle(Offset(cx, cy), 9, sh);
    c.drawCircle(Offset(cx, cy), 8.5, ln);
    c.drawCircle(Offset(cx, cy), 1.5, dot);
  }

  void _scopeOverlay(Canvas c, double cx, double cy) {
    final p = Paint()
      ..color = VColors.teal.withOpacity(0.55)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    c.drawCircle(Offset(cx, cy), 26, p);
    c.drawCircle(Offset(cx, cy), 48, p..color = VColors.teal.withOpacity(0.25));
  }

  @override
  bool shouldRepaint(_CrosshairPainter o) => o.style != style || o.scoped != scoped;
}
