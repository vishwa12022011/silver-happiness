// ─────────────────────────────────────────────
//  hud_provider.dart
//  ChangeNotifier that owns all runtime HUD state
// ─────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hud_config.dart';

class HudProvider extends ChangeNotifier {
  HudConfig _config = HudConfig.defaultConfig();

  // ── Runtime state ────────────────────────────
  bool _editMode = false;
  String? _selectedId;
  SprintMode _sprintMode = SprintMode.none;
  WeaponSlot _activeWeapon = WeaponSlot.primary;
  final Set<AbilitySlot> _activeAbilities = {};
  bool _isCrouching = false;
  bool _isScoped = false;
  bool _showLeaderboard = false;
  bool _showShop = false;

  // Ultimate orb tracking
  int _ultimateOrbs = 4;
  final int _maxUltimateOrbs = 7;

  // Ability cooldowns (seconds remaining, 0 = ready)
  final Map<AbilitySlot, int> _cooldowns = {
    AbilitySlot.c: 0,
    AbilitySlot.q: 0,
    AbilitySlot.e: 0,
    AbilitySlot.x: 0,
  };

  // ── Getters ──────────────────────────────────
  HudConfig get config => _config;
  bool get editMode => _editMode;
  String? get selectedId => _selectedId;
  SprintMode get sprintMode => _sprintMode;
  WeaponSlot get activeWeapon => _activeWeapon;
  Set<AbilitySlot> get activeAbilities => Set.unmodifiable(_activeAbilities);
  bool get isCrouching => _isCrouching;
  bool get isScoped => _isScoped;
  bool get showLeaderboard => _showLeaderboard;
  bool get showShop => _showShop;
  int get ultimateOrbs => _ultimateOrbs;
  int get maxUltimateOrbs => _maxUltimateOrbs;
  bool get ultimateReady => _ultimateOrbs >= _maxUltimateOrbs;
  Map<AbilitySlot, int> get cooldowns => Map.unmodifiable(_cooldowns);

  // ── Edit mode ────────────────────────────────
  void toggleEditMode() {
    _editMode = !_editMode;
    if (!_editMode) _selectedId = null;
    notifyListeners();
  }

  void selectElement(String? id) {
    _selectedId = id;
    notifyListeners();
  }

  // ── Element mutation ─────────────────────────
  void updatePosition(String id, double x, double y) {
    final el = _config.elements[id];
    if (el == null) return;
    _config.elements[id] = el.copyWith(x: x.clamp(0.0, 1.0), y: y.clamp(0.0, 1.0));
    notifyListeners();
  }

  void updateSize(String id, double size) {
    final el = _config.elements[id];
    if (el == null) return;
    _config.elements[id] = el.copyWith(size: size.clamp(0.3, 2.5));
    notifyListeners();
  }

  void updateOpacity(String id, double opacity) {
    final el = _config.elements[id];
    if (el == null) return;
    _config.elements[id] = el.copyWith(opacity: opacity.clamp(0.1, 1.0));
    notifyListeners();
  }

  void updateKeyMapping(String id, String key) {
    final el = _config.elements[id];
    if (el == null) return;
    _config.elements[id] = el.copyWith(keyMapping: key);
    notifyListeners();
  }

  void toggleVisibility(String id) {
    final el = _config.elements[id];
    if (el == null) return;
    _config.elements[id] = el.copyWith(visible: !el.visible);
    notifyListeners();
  }

  // ── Game actions ─────────────────────────────
  void setSprintMode(SprintMode mode) {
    if (_sprintMode == mode) return;
    _sprintMode = mode;
    notifyListeners();
  }

  void setActiveWeapon(WeaponSlot slot) {
    _activeWeapon = slot;
    notifyListeners();
  }

  void triggerAbility(AbilitySlot slot) {
    _activeAbilities.add(slot);
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 280), () {
      _activeAbilities.remove(slot);
      notifyListeners();
    });
  }

  void toggleCrouch() {
    _isCrouching = !_isCrouching;
    notifyListeners();
  }

  void toggleScope() {
    _isScoped = !_isScoped;
    notifyListeners();
  }

  void setShowLeaderboard(bool v) {
    _showLeaderboard = v;
    notifyListeners();
  }

  void toggleShop() {
    _showShop = !_showShop;
    notifyListeners();
  }

  void setCrosshairStyle(CrosshairStyle style) {
    _config.crosshairStyle = style;
    notifyListeners();
  }

  // ── Persistence ──────────────────────────────
  void resetToDefault() {
    _config = HudConfig.defaultConfig();
    notifyListeners();
  }

  Future<void> saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = {
        'elements': _config.elements.map((k, v) => MapEntry(k, v.toJson())),
        'crosshairStyle': _config.crosshairStyle.index,
      };
      await prefs.setString('hud_config_v1', jsonEncode(map));
    } catch (_) {}
  }

  Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('hud_config_v1');
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final elemsJson = map['elements'] as Map<String, dynamic>;
      final loaded = elemsJson.map(
        (k, v) => MapEntry(k, HudElement.fromJson(v as Map<String, dynamic>)),
      );
      _config = HudConfig(
        elements: {...HudConfig.defaultConfig().elements, ...loaded},
        crosshairStyle: CrosshairStyle.values[map['crosshairStyle'] as int? ?? 0],
      );
      notifyListeners();
    } catch (_) {}
  }
}
