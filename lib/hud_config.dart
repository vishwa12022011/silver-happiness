// ─────────────────────────────────────────────
//  hud_config.dart
//  Data models for all HUD element configuration
// ─────────────────────────────────────────────

enum WeaponSlot { primary, pistol, melee, throwable }

enum AbilitySlot { c, q, e, x }

enum SprintMode { none, walk, sprint }

enum CrosshairStyle { valoCross, cross, dot, circle }

// ── HudElement ───────────────────────────────
class HudElement {
  final String id;
  final String label;
  double x;        // 0.0–1.0 (normalised to screen width)
  double y;        // 0.0–1.0 (normalised to screen height)
  double size;     // multiplier: 1.0 = default
  double opacity;  // 0.0–1.0
  String keyMapping;
  bool visible;

  HudElement({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    this.size = 1.0,
    this.opacity = 1.0,
    this.keyMapping = '',
    this.visible = true,
  });

  HudElement copyWith({
    double? x,
    double? y,
    double? size,
    double? opacity,
    String? keyMapping,
    bool? visible,
  }) =>
      HudElement(
        id: id,
        label: label,
        x: x ?? this.x,
        y: y ?? this.y,
        size: size ?? this.size,
        opacity: opacity ?? this.opacity,
        keyMapping: keyMapping ?? this.keyMapping,
        visible: visible ?? this.visible,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'x': x,
        'y': y,
        'size': size,
        'opacity': opacity,
        'keyMapping': keyMapping,
        'visible': visible,
      };

  factory HudElement.fromJson(Map<String, dynamic> j) => HudElement(
        id: j['id'] as String,
        label: j['label'] as String,
        x: (j['x'] as num).toDouble(),
        y: (j['y'] as num).toDouble(),
        size: (j['size'] as num?)?.toDouble() ?? 1.0,
        opacity: (j['opacity'] as num?)?.toDouble() ?? 1.0,
        keyMapping: j['keyMapping'] as String? ?? '',
        visible: j['visible'] as bool? ?? true,
      );
}

// ── HudConfig ────────────────────────────────
class HudConfig {
  final Map<String, HudElement> elements;
  CrosshairStyle crosshairStyle;
  bool editMode;

  HudConfig({
    required this.elements,
    this.crosshairStyle = CrosshairStyle.valoCross,
    this.editMode = false,
  });

  static HudConfig defaultConfig() => HudConfig(
        elements: {
          // ── Movement ──────────────────────────────────────
          'joystick':     HudElement(id: 'joystick',    label: 'Move',     x: 0.10, y: 0.68, size: 1.0,  opacity: 0.85),
          'sprint':       HudElement(id: 'sprint',      label: 'Sprint',   x: 0.20, y: 0.84, size: 0.90, opacity: 0.90, keyMapping: 'Shift'),

          // ── Fire ──────────────────────────────────────────
          'fire_right':   HudElement(id: 'fire_right',  label: 'Fire',     x: 0.88, y: 0.70, size: 1.25, opacity: 0.95),
          'fire_left':    HudElement(id: 'fire_left',   label: 'ADS',      x: 0.24, y: 0.54, size: 0.85, opacity: 0.85),

          // ── Utility ───────────────────────────────────────
          'scope':        HudElement(id: 'scope',       label: 'Scope',    x: 0.76, y: 0.86, size: 0.85, opacity: 0.88, keyMapping: 'RMB'),
          'crouch':       HudElement(id: 'crouch',      label: 'Crouch',   x: 0.82, y: 0.88, size: 0.82, opacity: 0.88, keyMapping: 'Ctrl'),
          'jump':         HudElement(id: 'jump',        label: 'Jump',     x: 0.91, y: 0.88, size: 0.82, opacity: 0.88, keyMapping: 'Space'),
          'reload':       HudElement(id: 'reload',      label: 'Reload',   x: 0.74, y: 0.77, size: 0.82, opacity: 0.88, keyMapping: 'R'),
          'interact':     HudElement(id: 'interact',    label: 'Use',      x: 0.68, y: 0.68, size: 0.82, opacity: 0.88, keyMapping: 'F'),
          'gun_switch':   HudElement(id: 'gun_switch',  label: 'Switch',   x: 0.62, y: 0.88, size: 0.82, opacity: 0.88, keyMapping: 'Q'),

          // ── Top bar ───────────────────────────────────────
          'shop':         HudElement(id: 'shop',        label: 'Shop',     x: 0.50, y: 0.06, size: 0.80, opacity: 0.88, keyMapping: 'B'),
          'emoji':        HudElement(id: 'emoji',       label: 'Emote',    x: 0.58, y: 0.06, size: 0.75, opacity: 0.82),
          'leaderboard':  HudElement(id: 'leaderboard', label: 'Team',     x: 0.42, y: 0.06, size: 0.75, opacity: 0.82, keyMapping: 'Tab'),

          // ── Weapon slots ──────────────────────────────────
          'slot_primary':   HudElement(id: 'slot_primary',   label: 'Primary',  x: 0.87, y: 0.54, size: 1.0,  opacity: 0.92),
          'slot_pistol':    HudElement(id: 'slot_pistol',    label: 'Pistol',   x: 0.94, y: 0.54, size: 0.82, opacity: 0.88),
          'slot_melee':     HudElement(id: 'slot_melee',     label: 'Melee',    x: 0.87, y: 0.45, size: 0.78, opacity: 0.85),
          'slot_throwable': HudElement(id: 'slot_throwable', label: 'Throw',    x: 0.94, y: 0.45, size: 0.78, opacity: 0.85),

          // ── Abilities ─────────────────────────────────────
          'ability_c': HudElement(id: 'ability_c', label: 'C', x: 0.30, y: 0.88, size: 1.0,  opacity: 0.92, keyMapping: 'C'),
          'ability_q': HudElement(id: 'ability_q', label: 'Q', x: 0.38, y: 0.88, size: 1.0,  opacity: 0.92, keyMapping: 'Q'),
          'ability_e': HudElement(id: 'ability_e', label: 'E', x: 0.46, y: 0.88, size: 1.0,  opacity: 0.92, keyMapping: 'E'),
          'ability_x': HudElement(id: 'ability_x', label: 'X', x: 0.55, y: 0.88, size: 1.10, opacity: 0.95, keyMapping: 'X'),

          // ── Minimap ───────────────────────────────────────
          'minimap': HudElement(id: 'minimap', label: 'Map', x: 0.05, y: 0.08, size: 1.0, opacity: 0.88),
        },
      );
}
