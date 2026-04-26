# 🎮 Valorant Mobile HUD Controller

A fully-customisable game HUD overlay inspired by **Free Fire** and styled after **Valorant**, built with Flutter.

---

## Features

| Category | Details |
|---|---|
| **Joystick** | Slow push → walk · Normal drag → walk · Push up → sprint · External sprint button |
| **Weapon slots** | Primary · Pistol · Melee · Throwable (Valorant throwable replaces secondary) |
| **Buttons** | Crouch · Jump · Interact (plant/defuse) · Reload · Gun switch · Shop · Emoji · Team leaderboard (hold) |
| **Abilities** | C / Q / E / X with cooldown indicators, charge pips & ultimate orb tracking |
| **Crosshair** | 4 styles: Valorant Cross · Classic Cross · Dot · Circle · Scope overlay |
| **Extra controls** | Left-side ADS/fire · Scope toggle · Minimap |
| **Edit mode** | Drag any button to reposition · Resize (0.3 – 2.5×) · Set opacity · Remap key label · Toggle visibility · Persisted via SharedPreferences |

---

## Building

### Prerequisites
- Flutter ≥ 3.10.0
- Java 17 (Temurin recommended)
- Android SDK with `compileSdk 35`

### Local build
```bash
flutter pub get
flutter build apk --release
# APK → build/app/outputs/flutter-apk/app-release.apk
```

### GitHub Actions
Push to `main` / `master` → the workflow in `.github/workflows/build.yml` runs automatically and uploads the APK as an artifact.

---

## Project Structure
```
hud_controller/
├── .github/workflows/build.yml   # CI/CD
├── pubspec.yaml
├── lib/
│   ├── main.dart                 # Entry point + HUD screen
│   ├── hud_config.dart           # Data models (HudElement, HudConfig, enums)
│   ├── hud_provider.dart         # ChangeNotifier state manager
│   ├── valorant_theme.dart       # Colours, text styles, decorations
│   ├── hud_joystick.dart         # Joystick with sprint detection
│   ├── hud_button.dart           # Draggable positioned button
│   ├── simple_hud_button.dart    # Icon + label convenience wrapper
│   ├── crosshair_widget.dart     # Custom-painted crosshair (4 styles)
│   ├── weapon_slots.dart         # Weapon slot tiles
│   ├── ability_buttons.dart      # Ability + ultimate buttons
│   ├── fire_button.dart          # Animated fire / ADS button
│   └── edit_panel.dart           # Bottom edit panel (size/opacity/key)
└── android/                      # Complete Android project (embedding v2)
```
