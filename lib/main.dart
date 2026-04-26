// ─────────────────────────────────────────────
//  main.dart
//  Entry point + HUD screen assembly
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'hud_config.dart';
import 'hud_provider.dart';
import 'valorant_theme.dart';
import 'hud_joystick.dart';
import 'hud_button.dart';
import 'simple_hud_button.dart';
import 'crosshair_widget.dart';
import 'weapon_slots.dart';
import 'ability_buttons.dart';
import 'fire_button.dart';
import 'edit_panel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    ChangeNotifierProvider(
      create: (_) => HudProvider()..loadConfig(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valorant HUD Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: VColors.darkBg,
        colorScheme: const ColorScheme.dark(primary: VColors.red, secondary: VColors.teal),
        useMaterial3: true,
      ),
      home: const HudScreen(),
    );
  }
}

// ═══════════════════════════════════════════════
//  HUD Screen
// ═══════════════════════════════════════════════
class HudScreen extends StatelessWidget {
  const HudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov     = context.watch<HudProvider>();
    final editMode = prov.editMode;
    final cfg      = prov.config;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Mock game background ─────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D1B2A), Color(0xFF1A1A2E), Color(0xFF0F1923)],
              ),
            ),
          ),
          // Demo map silhouette lines
          CustomPaint(painter: _MapHintPainter(), size: Size.infinite),

          // ── Edit-mode dimmed overlay ─────────
          if (editMode)
            Container(color: Colors.black.withOpacity(0.30)),

          // ╔══════════════════════════════════╗
          //  LAYOUT STACK (all in one Stack)
          // ╚══════════════════════════════════╝
          _HudLayer(),

          // ── Edit panel (bottom) ──────────────
          Column(children: [
            const Spacer(),
            const EditPanel(),
          ]),

          // ── Top-right toolbar ────────────────
          Positioned(
            top: 8, right: 8,
            child: _TopBar(prov: prov, editMode: editMode),
          ),

          // ── Leaderboard overlay ──────────────
          if (prov.showLeaderboard) const _LeaderboardOverlay(),

          // ── Shop overlay ─────────────────────
          if (prov.showShop) const _ShopOverlay(),
        ],
      ),
    );
  }
}

// ── All draggable HUD elements ────────────────
class _HudLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<HudProvider>();
    final cfg  = prov.config;

    return LayoutBuilder(builder: (ctx, box) {
      final sw = box.maxWidth;
      final sh = box.maxHeight;

      Widget positioned(String id, Widget child,
          {double baseSize = 46, VoidCallback? onTap, VoidCallback? onLongPress,
           Color accent = VColors.red, bool circular = false}) {
        final el = cfg.elements[id];
        if (el == null || !el.visible) return const SizedBox.shrink();
        return HudButton(
          elementId: id, baseSize: baseSize,
          onTap: onTap, onLongPress: onLongPress,
          accentColor: accent, circular: circular,
          child: child,
        );
      }

      return Stack(children: [
        // ── Minimap (top-left) ───────────────
        positioned('minimap', _Minimap(), baseSize: 90, accent: VColors.border),

        // ── Joystick (bottom-left) ───────────
        positioned('joystick', const HudJoystick(), baseSize: 124, accent: VColors.white),

        // ── Sprint button ────────────────────
        SimpleHudButton(
          elementId: 'sprint', icon: Icons.directions_run, label: 'Sprint',
          accentColor: VColors.offWhite,
          onTap: () => prov.setSprintMode(SprintMode.sprint),
        ),

        // ── Left fire / ADS ─────────────────
        positioned('fire_left',
          const FireButton(elementId: 'fire_left', isLeft: true, baseSize: 60),
          baseSize: 60, accent: VColors.teal, circular: true),

        // ── Right fire ───────────────────────
        positioned('fire_right',
          const FireButton(elementId: 'fire_right', isLeft: false, baseSize: 74),
          baseSize: 74, accent: VColors.red, circular: true),

        // ── Scope ────────────────────────────
        SimpleHudButton(
          elementId: 'scope', icon: Icons.center_focus_strong, label: 'Scope',
          accentColor: VColors.teal,
          onTap: () => prov.toggleScope(),
        ),

        // ── Crouch ───────────────────────────
        SimpleHudButton(
          elementId: 'crouch', icon: Icons.airline_seat_recline_normal, label: 'Crouch',
          accentColor: prov.isCrouching ? VColors.teal : VColors.red,
          onTap: () => prov.toggleCrouch(),
        ),

        // ── Jump ─────────────────────────────
        SimpleHudButton(
          elementId: 'jump', icon: Icons.keyboard_arrow_up_rounded, label: 'Jump',
          accentColor: VColors.red,
        ),

        // ── Reload ───────────────────────────
        SimpleHudButton(
          elementId: 'reload', icon: Icons.refresh_rounded, label: 'Reload',
          accentColor: VColors.gold,
        ),

        // ── Interact ─────────────────────────
        SimpleHudButton(
          elementId: 'interact', icon: Icons.touch_app_rounded, label: 'Use/Plant',
          accentColor: VColors.green,
        ),

        // ── Gun switch ───────────────────────
        SimpleHudButton(
          elementId: 'gun_switch', icon: Icons.swap_horiz_rounded, label: 'Switch',
          accentColor: VColors.offWhite,
        ),

        // ── Shop ─────────────────────────────
        SimpleHudButton(
          elementId: 'shop', icon: Icons.storefront_rounded, label: 'Shop',
          accentColor: VColors.gold,
          onTap: () => prov.toggleShop(),
        ),

        // ── Emoji / Emote ────────────────────
        SimpleHudButton(
          elementId: 'emoji', icon: Icons.tag_faces_rounded, label: 'Emote',
          accentColor: VColors.cyan,
        ),

        // ── Leaderboard / Team (hold) ────────
        SimpleHudButton(
          elementId: 'leaderboard', icon: Icons.people_alt_rounded, label: 'Team',
          accentColor: VColors.offWhite,
          onLongPress: () => prov.setShowLeaderboard(!prov.showLeaderboard),
        ),

        // ── Weapon slots (top-right cluster) ─
        positioned('slot_primary',
          _WeaponIcon(slot: WeaponSlot.primary, prov: prov),
          baseSize: 90, accent: VColors.red),
        positioned('slot_pistol',
          _WeaponIcon(slot: WeaponSlot.pistol, prov: prov),
          baseSize: 55, accent: VColors.offWhite),
        positioned('slot_melee',
          _WeaponIcon(slot: WeaponSlot.melee, prov: prov),
          baseSize: 50, accent: VColors.teal),
        positioned('slot_throwable',
          _WeaponIcon(slot: WeaponSlot.throwable, prov: prov),
          baseSize: 50, accent: VColors.gold),

        // ── Abilities bar ────────────────────
        positioned('ability_c', _AbilityIcon(slot: AbilitySlot.c, label: 'C', icon: Icons.radio_button_checked, prov: prov), baseSize: 56, accent: VColors.abilityFg),
        positioned('ability_q', _AbilityIcon(slot: AbilitySlot.q, label: 'Q', icon: Icons.cloud_outlined, prov: prov), baseSize: 56, accent: VColors.abilityFg),
        positioned('ability_e', _AbilityIcon(slot: AbilitySlot.e, label: 'E', icon: Icons.track_changes_rounded, prov: prov, sig: true), baseSize: 56, accent: VColors.teal),
        positioned('ability_x', _AbilityIcon(slot: AbilitySlot.x, label: 'X', icon: Icons.bolt_rounded, prov: prov, ult: true), baseSize: 66, accent: VColors.red),

        // ── Crosshair (center) ───────────────
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.center,
              child: CrosshairWidget(style: cfg.crosshairStyle, scoped: prov.isScoped),
            ),
          ),
        ),

        // ── Health / Shield bar (bottom-left) ─
        Positioned(
          bottom: 12, left: 170,
          child: const _StatusBars(),
        ),

        // ── Round / Score info (top-center) ──
        Positioned(
          top: 8, left: 0, right: 0,
          child: const Center(child: _RoundInfo()),
        ),
      ]);
    });
  }
}

// ── Inline small helpers ──────────────────────
class _WeaponIcon extends StatelessWidget {
  final WeaponSlot slot;
  final HudProvider prov;
  const _WeaponIcon({required this.slot, required this.prov});
  @override
  Widget build(BuildContext context) {
    final icons = {
      WeaponSlot.primary:   Icons.hardware_outlined,
      WeaponSlot.pistol:    Icons.adjust,
      WeaponSlot.melee:     Icons.sports_kabaddi,
      WeaponSlot.throwable: Icons.circle_outlined,
    };
    final labels = {
      WeaponSlot.primary: 'VANDAL', WeaponSlot.pistol: 'GHOST',
      WeaponSlot.melee: 'KNIFE', WeaponSlot.throwable: 'FRAG',
    };
    final active = prov.activeWeapon == slot;
    final color  = active ? VColors.red : VColors.offWhite.withOpacity(0.55);
    return GestureDetector(
      onTap: () => prov.setActiveWeapon(slot),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icons[slot], color: color, size: 16),
        Text(labels[slot]!, style: VTheme.label(size: 7.5, color: color)),
        if (slot == WeaponSlot.primary && active)
          Text('25/75', style: VTheme.label(size: 8.5, color: VColors.red)),
      ]),
    );
  }
}

class _AbilityIcon extends StatelessWidget {
  final AbilitySlot slot;
  final String label;
  final IconData icon;
  final HudProvider prov;
  final bool sig, ult;
  const _AbilityIcon({required this.slot, required this.label, required this.icon,
      required this.prov, this.sig = false, this.ult = false});
  @override
  Widget build(BuildContext context) {
    final active = prov.activeAbilities.contains(slot);
    final ready  = ult ? prov.ultimateReady : true;
    final color  = ult ? VColors.red : (sig ? VColors.teal : VColors.abilityFg);
    return GestureDetector(
      onTap: () => prov.triggerAbility(slot),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: ready ? color : VColors.offWhite.withOpacity(0.35), size: ult ? 22 : 18),
        Text(label, style: VTheme.label(size: 9, color: ready ? Colors.white : VColors.offWhite.withOpacity(0.4))),
        if (ult)
          Row(mainAxisSize: MainAxisSize.min, children: [
            for (int i = 0; i < prov.maxUltimateOrbs; i++)
              Container(width: 4, height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: i < prov.ultimateOrbs ? VColors.red : VColors.border.withOpacity(0.4)),
              ),
          ]),
      ]),
    );
  }
}

// ── Minimap ───────────────────────────────────
class _Minimap extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 90, height: 90,
    decoration: BoxDecoration(
      color: VColors.darkBg.withOpacity(0.88),
      border: Border.all(color: VColors.border),
      borderRadius: BorderRadius.circular(4),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: CustomPaint(painter: _MapPainter()),
    ),
  );
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final grid = Paint()..color = VColors.border.withOpacity(0.3)..strokeWidth = 0.5;
    for (int i = 0; i <= 5; i++) {
      final step = s.width / 5;
      c.drawLine(Offset(step * i, 0), Offset(step * i, s.height), grid);
      c.drawLine(Offset(0, step * i), Offset(s.width, step * i), grid);
    }
    final block = Paint()..color = VColors.border.withOpacity(0.38)..style = PaintingStyle.fill;
    for (final r in [
      Rect.fromLTWH(4, 8, 22, 9), Rect.fromLTWH(58, 14, 24, 10),
      Rect.fromLTWH(14, 62, 20, 13), Rect.fromLTWH(54, 58, 26, 9),
      Rect.fromLTWH(28, 28, 32, 22),
    ]) {
      c.drawRect(r, block);
    }
    c.drawRect(Rect.fromCenter(center: Offset(s.width * 0.20, s.height * 0.24), width: 10, height: 10),
        Paint()..color = VColors.red.withOpacity(0.50)..style = PaintingStyle.fill);
    c.drawRect(Rect.fromCenter(center: Offset(s.width * 0.79, s.height * 0.76), width: 10, height: 10),
        Paint()..color = VColors.teal.withOpacity(0.50)..style = PaintingStyle.fill);
    // Player dot
    c.drawCircle(Offset(s.width / 2, s.height / 2), 4,
        Paint()..color = VColors.teal..style = PaintingStyle.fill);
  }
  @override
  bool shouldRepaint(_) => false;
}

// ── Status bars ───────────────────────────────
class _StatusBars extends StatelessWidget {
  const _StatusBars();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('HP  100', style: VTheme.label(size: 10, color: VColors.green)),
      const SizedBox(height: 3),
      _Bar(value: 1.0, color: VColors.green, width: 120),
      const SizedBox(height: 4),
      Text('SHIELD  50', style: VTheme.label(size: 10, color: VColors.cyan)),
      const SizedBox(height: 3),
      _Bar(value: 0.50, color: VColors.cyan, width: 120),
    ],
  );
}

class _Bar extends StatelessWidget {
  final double value, width;
  final Color color;
  const _Bar({required this.value, required this.color, required this.width});
  @override
  Widget build(BuildContext context) => Container(
    width: width, height: 5,
    decoration: BoxDecoration(color: VColors.darkBg2, borderRadius: BorderRadius.circular(3)),
    child: FractionallySizedBox(
      alignment: Alignment.centerLeft, widthFactor: value,
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3),
            boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)]),
      ),
    ),
  );
}

// ── Round info bar ────────────────────────────
class _RoundInfo extends StatelessWidget {
  const _RoundInfo();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: VColors.darkBg.withOpacity(0.75),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: VColors.border),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text('5', style: VTheme.label(size: 18, color: VColors.red)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(':', style: VTheme.label(size: 18, color: VColors.white)),
      ),
      Text('7', style: VTheme.label(size: 18, color: VColors.teal)),
      const SizedBox(width: 20),
      Text('1:12', style: VTheme.label(size: 14, color: VColors.offWhite)),
    ]),
  );
}

// ── Top bar (edit toggle, save, crosshair cycle) ──
class _TopBar extends StatelessWidget {
  final HudProvider prov;
  final bool editMode;
  const _TopBar({required this.prov, required this.editMode});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    _ToolBtn(icon: Icons.edit_rounded, label: editMode ? 'DONE' : 'EDIT',
        color: editMode ? VColors.gold : VColors.offWhite,
        onTap: editMode ? () { prov.toggleEditMode(); prov.saveConfig(); } : prov.toggleEditMode),
    const SizedBox(width: 6),
    _ToolBtn(icon: Icons.gps_fixed_rounded, label: 'AIM',
        color: VColors.offWhite,
        onTap: () {
          final next = CrosshairStyle.values[(prov.config.crosshairStyle.index + 1) % CrosshairStyle.values.length];
          prov.setCrosshairStyle(next);
        }),
    const SizedBox(width: 6),
    _ToolBtn(icon: Icons.restore_rounded, label: 'RESET',
        color: VColors.red,
        onTap: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: VColors.panelBg,
            title: Text('Reset HUD?', style: VTheme.label(size: 14, color: VColors.red)),
            content: Text('This will restore all buttons to default positions.', style: VTheme.label(size: 11, color: VColors.offWhite)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: VTheme.label(size: 11, color: VColors.white))),
              TextButton(onPressed: () { prov.resetToDefault(); Navigator.pop(context); }, child: Text('Reset', style: VTheme.label(size: 11, color: VColors.red))),
            ],
          ),
        )),
  ]);
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ToolBtn({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: VColors.panelBg.withOpacity(0.90),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.55)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(label, style: VTheme.label(size: 9, color: color)),
      ]),
    ),
  );
}

// ── Overlays ──────────────────────────────────
class _LeaderboardOverlay extends StatelessWidget {
  const _LeaderboardOverlay();
  @override
  Widget build(BuildContext context) => Positioned.fill(child: GestureDetector(
    onTap: () => context.read<HudProvider>().setShowLeaderboard(false),
    child: Container(
      color: Colors.black.withOpacity(0.72),
      alignment: Alignment.center,
      child: Container(
        width: 420, height: 220,
        decoration: BoxDecoration(
          color: VColors.panelBg,
          border: Border.all(color: VColors.red, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('SCOREBOARD', style: VTheme.label(size: 14, color: VColors.red)),
          const SizedBox(height: 12),
          for (final row in [['PLAYER', 'K', 'D', 'A', 'ACS'],
               ['Phoenix',  '14', '6', '4', '268'],
               ['Jett',     '11', '8', '7', '210'],
               ['Sage',     '5',  '9', '12','140'],
               ['Omen',     '8',  '10','3', '188']]) ...[
            Row(children: row.asMap().entries.map((e) => Expanded(child: Text(e.value,
              style: VTheme.label(size: 10, color: e.key == 0 ? VColors.offWhite : VColors.white),
              textAlign: TextAlign.center))).toList()),
            const SizedBox(height: 4),
          ],
        ]),
      ),
    ),
  ));
}

class _ShopOverlay extends StatelessWidget {
  const _ShopOverlay();
  @override
  Widget build(BuildContext context) => Positioned.fill(child: GestureDetector(
    onTap: () => context.read<HudProvider>().toggleShop(),
    child: Container(
      color: Colors.black.withOpacity(0.78),
      alignment: Alignment.center,
      child: Container(
        width: 480, height: 280,
        decoration: BoxDecoration(
          color: VColors.panelBg,
          border: Border.all(color: VColors.gold, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('SHOP', style: VTheme.label(size: 15, color: VColors.gold)),
            const Spacer(),
            Text('3,900 CR', style: VTheme.label(size: 13, color: VColors.gold)),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final item in [('Vandal', '2,900'), ('Phantom', '2,900'), ('Operator', '4,700'),
                                ('Ghost', '500'),   ('Shorty', '150'),   ('Frag', '200')])
              Container(
                width: 120, height: 60,
                decoration: BoxDecoration(
                  color: VColors.darkBg2,
                  border: Border.all(color: VColors.border),
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(item.$1, style: VTheme.label(size: 10, color: VColors.white)),
                  Text(item.$2, style: VTheme.label(size: 10, color: VColors.gold)),
                ]),
              ),
          ]),
        ]),
      ),
    ),
  ));
}

// ── Background map hint painter ───────────────
class _MapHintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = VColors.border.withOpacity(0.08)..strokeWidth = 1..style = PaintingStyle.stroke;
    // A few diagonal lines for atmosphere
    canvas.drawLine(const Offset(0, 0), Offset(size.width * 0.4, size.height), p);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.7, size.height), p);
    canvas.drawLine(Offset(size.width * 0.6, 0), Offset(size.width, size.height * 0.8), p);
  }
  @override
  bool shouldRepaint(_) => false;
}
