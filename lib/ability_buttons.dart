// ─────────────────────────────────────────────
//  ability_buttons.dart
//  Four Valorant ability buttons (C / Q / E / X)
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'hud_config.dart';
import 'hud_provider.dart';
import 'valorant_theme.dart';

class AbilityButtons extends StatelessWidget {
  const AbilityButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final prov     = context.watch<HudProvider>();
    final active   = prov.activeAbilities;
    final cooldown = prov.cooldowns;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Ability(
          slot: AbilitySlot.c, label: 'C', subLabel: 'Stim Beacon',
          icon: Icons.radio_button_checked,
          isActive: active.contains(AbilitySlot.c),
          cooldown: cooldown[AbilitySlot.c] ?? 0,
          charges: 1,
          onTap: () => prov.triggerAbility(AbilitySlot.c),
        ),
        const SizedBox(width: 6),
        _Ability(
          slot: AbilitySlot.q, label: 'Q', subLabel: 'Sky Smoke',
          icon: Icons.cloud_outlined,
          isActive: active.contains(AbilitySlot.q),
          cooldown: cooldown[AbilitySlot.q] ?? 0,
          charges: 2,
          onTap: () => prov.triggerAbility(AbilitySlot.q),
        ),
        const SizedBox(width: 6),
        _Ability(
          slot: AbilitySlot.e, label: 'E', subLabel: 'Orbital',
          icon: Icons.track_changes_rounded,
          isActive: active.contains(AbilitySlot.e),
          cooldown: cooldown[AbilitySlot.e] ?? 0,
          charges: 1,
          isSignature: true,
          onTap: () => prov.triggerAbility(AbilitySlot.e),
        ),
        const SizedBox(width: 8),
        _Ultimate(
          slot: AbilitySlot.x, label: 'X',
          icon: Icons.bolt_rounded,
          isActive: active.contains(AbilitySlot.x),
          orbsFilled: prov.ultimateOrbs,
          orbsMax:    prov.maxUltimateOrbs,
          isReady:    prov.ultimateReady,
          onTap: prov.ultimateReady ? () => prov.triggerAbility(AbilitySlot.x) : null,
        ),
      ],
    );
  }
}

// ── Regular ability tile ──────────────────────
class _Ability extends StatelessWidget {
  final AbilitySlot slot;
  final String label, subLabel;
  final IconData icon;
  final bool isActive, isSignature;
  final int cooldown, charges;
  final VoidCallback onTap;

  const _Ability({
    required this.slot, required this.label, required this.subLabel,
    required this.icon, required this.isActive,
    required this.cooldown, required this.charges,
    this.isSignature = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onCD  = cooldown > 0;
    final color = isSignature ? VColors.teal : VColors.abilityFg;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 56, height: 56,
        decoration: VTheme.abilityBox(active: isActive),
        child: Stack(
          children: [
            if (isActive)
              Container(decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                gradient: RadialGradient(colors: [color.withOpacity(0.28), Colors.transparent]),
              )),
            Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon,
                  color: onCD ? VColors.offWhite.withOpacity(0.30) : (isActive ? Colors.white : color),
                  size: 20),
              const SizedBox(height: 2),
              Text(label, style: VTheme.label(size: 9.5,
                  color: onCD ? VColors.offWhite.withOpacity(0.35) : (isActive ? Colors.white : color))),
            ])),
            // Cooldown overlay
            if (onCD)
              Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.52), borderRadius: BorderRadius.circular(9)),
                child: Center(child: Text('$cooldown', style: VTheme.label(size: 15, color: VColors.white))),
              ),
            // Charge pips
            if (charges > 1)
              Positioned(bottom: 4, left: 0, right: 0,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (int i = 0; i < charges; i++)
                    Container(
                      width: 5, height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(i < charges ? 1 : 0.25)),
                    ),
                ]),
              ),
            // Key label top-left
            Positioned(top: 3, left: 4,
              child: Text(label, style: VTheme.label(size: 7, color: VColors.offWhite.withOpacity(0.55)))),
          ],
        ),
      ),
    );
  }
}

// ── Ultimate tile ─────────────────────────────
class _Ultimate extends StatelessWidget {
  final AbilitySlot slot;
  final String label;
  final IconData icon;
  final bool isActive, isReady;
  final int orbsFilled, orbsMax;
  final VoidCallback? onTap;

  const _Ultimate({
    required this.slot, required this.label, required this.icon,
    required this.isActive, required this.isReady,
    required this.orbsFilled, required this.orbsMax,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 66, height: 66,
      decoration: VTheme.abilityBox(active: isActive, isUlt: true),
      child: Stack(children: [
        if (isActive || isReady)
          Container(decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            gradient: RadialGradient(colors: [VColors.ultimateR.withOpacity(0.22), Colors.transparent]),
          )),
        Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: isReady ? VColors.red : VColors.offWhite.withOpacity(0.45), size: 24),
          const SizedBox(height: 2),
          Text(label, style: VTheme.label(size: 10, color: isReady ? VColors.white : VColors.offWhite.withOpacity(0.45))),
        ])),
        // Orb pips
        Positioned(bottom: 5, left: 0, right: 0,
          child: Center(child: Wrap(spacing: 2.5, children: [
            for (int i = 0; i < orbsMax; i++)
              Container(width: 4, height: 4, decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < orbsFilled ? VColors.red : VColors.border.withOpacity(0.5),
                boxShadow: i < orbsFilled
                    ? [BoxShadow(color: VColors.red.withOpacity(0.55), blurRadius: 4)]
                    : [],
              )),
          ]))),
        // READY badge
        if (isReady && !isActive)
          Positioned(top: 3, left: 0, right: 0,
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(color: VColors.red.withOpacity(0.82), borderRadius: BorderRadius.circular(3)),
              child: Text('READY', style: VTheme.label(size: 6.5, color: Colors.white)),
            ))),
      ]),
    ),
  );
}
