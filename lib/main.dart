// lib/widgets/weapon_slots.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hud_provider.dart';
import '../theme/valorant_theme.dart';

class WeaponSlotsWidget extends StatelessWidget {
  const WeaponSlotsWidget({super.key});

  static const _labels = ['PRIMARY', 'PISTOL', 'MELEE', 'THROW'];
  static const _icons = ['🔫', '🔫', '🗡️', '💣'];
  static const _keys = ['1', '2', '3', 'G'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HudProvider>();
    final config = provider.config;
    if (config == null) return const SizedBox.shrink();

    // Position comes from the primary weapon button config
    final primaryBtn = config.buttons['weapon_primary'];
    if (primaryBtn == null) return const SizedBox.shrink();

    return Positioned(
      left: primaryBtn.position.dx - 10,
      top: primaryBtn.position.dy,
      child: Opacity(
        opacity: primaryBtn.opacity,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (i) {
            final isActive = provider.activeWeapon == i;
            return GestureDetector(
              onTap: () => provider.setWeapon(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: isActive ? 58 : 48,
                height: isActive ? 58 : 48,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? ValorantColors.red.withOpacity(0.25)
                      : ValorantColors.panelBg.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isActive
                        ? ValorantColors.red
                        : ValorantColors.white.withOpacity(0.2),
                    width: isActive ? 2 : 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: ValorantColors.red.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_icons[i],
                        style: TextStyle(fontSize: isActive ? 18 : 14)),
                    const SizedBox(height: 2),
                    Text(
                      _keys[i],
                      style: valorantText(
                        size: 8,
                        color: isActive
                            ? ValorantColors.red
                            : ValorantColors.offWhite,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}