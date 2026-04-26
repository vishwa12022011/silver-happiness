// ─────────────────────────────────────────────
//  hud_button.dart
//  Draggable, resizable, opacity-aware HUD button
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'hud_provider.dart';
import 'valorant_theme.dart';

/// A fully positioned HUD button whose location is stored in [HudProvider].
/// In edit-mode it becomes draggable and shows a selection highlight.
class HudButton extends StatelessWidget {
  final String elementId;
  final Widget child;
  final double baseSize;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color accentColor;
  final bool circular;

  const HudButton({
    super.key,
    required this.elementId,
    required this.child,
    this.baseSize = 46,
    this.onTap,
    this.onLongPress,
    this.accentColor = VColors.red,
    this.circular = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, box) {
      final provider = ctx.watch<HudProvider>();
      final el = provider.config.elements[elementId];
      if (el == null || !el.visible) return const SizedBox.shrink();

      final sw       = box.maxWidth;
      final sh       = box.maxHeight;
      final sz       = baseSize * el.size;
      final px       = (el.x * sw - sz / 2).clamp(0.0, sw - sz);
      final py       = (el.y * sh - sz / 2).clamp(0.0, sh - sz);
      final editMode = provider.editMode;
      final selected = provider.selectedId == elementId;

      // ── Inner decorated box ───────────────────
      Widget inner = Opacity(
        opacity: el.opacity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: sz, height: sz,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.60),
            shape: circular ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: circular ? null : BorderRadius.circular(9),
            border: Border.all(
              color: selected
                  ? Colors.yellowAccent
                  : editMode
                      ? accentColor.withOpacity(0.55)
                      : accentColor.withOpacity(0.78),
              width: selected ? 2.5 : 1.5,
            ),
            boxShadow: [BoxShadow(
              color: accentColor.withOpacity(selected ? 0.65 : 0.22),
              blurRadius: selected ? 14 : 6,
              spreadRadius: selected ? 2 : 0,
            )],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              child,
              if (editMode)
                Positioned(
                  top: 2, right: 2,
                  child: Icon(Icons.open_with, color: Colors.yellowAccent.withOpacity(0.75), size: 8),
                ),
            ],
          ),
        ),
      );

      // ── Positioned + optional drag ────────────
      if (editMode) {
        return Positioned(
          left: px, top: py,
          child: GestureDetector(
            onTap: () => provider.selectElement(elementId),
            onPanUpdate: (d) {
              final nx = (el.x + d.delta.dx / sw).clamp(0.0, 1.0);
              final ny = (el.y + d.delta.dy / sh).clamp(0.0, 1.0);
              provider.updatePosition(elementId, nx, ny);
            },
            child: inner,
          ),
        );
      }

      return Positioned(
        left: px, top: py,
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: inner,
        ),
      );
    });
  }
}
