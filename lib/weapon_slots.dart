// ─────────────────────────────────────────────
//  weapon_slots.dart
//  Primary / Pistol / Melee / Throwable slots
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'hud_config.dart';
import 'hud_provider.dart';
import 'valorant_theme.dart';

class WeaponSlots extends StatelessWidget {
  const WeaponSlots({super.key});

  @override
  Widget build(BuildContext context) {
    final prov  = context.watch<HudProvider>();
    final active = prov.activeWeapon;
    void pick(WeaponSlot s) => prov.setActiveWeapon(s);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary – wide
        _Slot(slot: WeaponSlot.primary,   active: active, label: 'VANDAL',  ammo: '25 / 75',  icon: Icons.hardware_outlined,  onTap: () => pick(WeaponSlot.primary)),
        const SizedBox(height: 4),
        // Pistol + Melee side by side
        Row(mainAxisSize: MainAxisSize.min, children: [
          _Slot(slot: WeaponSlot.pistol,  active: active, label: 'GHOST',  icon: Icons.adjust,         compact: true, onTap: () => pick(WeaponSlot.pistol)),
          const SizedBox(width: 4),
          _Slot(slot: WeaponSlot.melee,   active: active, label: 'KNIFE',  icon: Icons.sports_kabaddi, compact: true, onTap: () => pick(WeaponSlot.melee)),
        ]),
        const SizedBox(height: 4),
        // Throwable
        _Slot(slot: WeaponSlot.throwable, active: active, label: 'FRAG ×2', icon: Icons.circle_outlined, compact: true, onTap: () => pick(WeaponSlot.throwable)),
      ],
    );
  }
}

// ── Private slot tile ─────────────────────────
class _Slot extends StatelessWidget {
  final WeaponSlot slot;
  final WeaponSlot active;
  final String label;
  final String? ammo;
  final IconData icon;
  final bool compact;
  final VoidCallback onTap;

  const _Slot({
    required this.slot,
    required this.active,
    required this.label,
    required this.icon,
    this.ammo,
    this.compact = false,
    required this.onTap,
  });

  Color get _accent => switch (slot) {
    WeaponSlot.primary   => VColors.red,
    WeaponSlot.pistol    => VColors.offWhite,
    WeaponSlot.melee     => VColors.teal,
    WeaponSlot.throwable => VColors.gold,
  };

  @override
  Widget build(BuildContext context) {
    final isActive = slot == active;
    final accent   = _accent;
    final w = compact ? 54.0 : 96.0;
    final h = compact ? 38.0 : 46.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: w, height: h,
        decoration: VTheme.weaponSlot(active: isActive, accent: accent),
        child: compact
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, color: isActive ? accent : VColors.offWhite.withOpacity(0.65), size: 14),
                const SizedBox(height: 2),
                Text(label.split(' ').first, style: VTheme.label(size: 7, color: isActive ? accent : VColors.offWhite.withOpacity(0.65))),
              ])
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(children: [
                  Icon(icon, color: isActive ? accent : VColors.offWhite.withOpacity(0.65), size: 20),
                  const SizedBox(width: 6),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:  MainAxisAlignment.center,
                    children: [
                      Text(label, style: VTheme.label(size: 8.5, color: isActive ? VColors.white : VColors.offWhite.withOpacity(0.70))),
                      if (ammo != null)
                        Text(ammo!, style: VTheme.label(size: 10, color: isActive ? accent : VColors.offWhite.withOpacity(0.50))),
                    ],
                  )),
                ]),
              ),
      ),
    );
  }
}
