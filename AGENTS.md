# AGENTS.md

## What this app does
`usb_file_finder` is a macOS-only Flutter desktop app. It scans USB/external
volumes (or arbitrary directories), indexes files by type into plain-text files
stored in `~/Documents/UsbFileFinder-Data/<deviceName>/<filetype>.txt`, and
lets the user search that index by keyword with filtering options. UI uses
`macos_ui` to match native AppKit appearance.

## Requirements
- **Platform**: macOS only (`flutter run/build` must target `-d macos`)
- **Dart SDK**: `>=3.0.0 <4.0.0`
- No pinned Flutter version (no FVM config / `.flutter-version`)

## Commands
```bash
flutter pub get          # install dependencies
flutter run -d macos     # run (macOS only)
flutter build macos      # release build
flutter test             # run tests
flutter analyze          # static analysis
dart format lib/ test/   # format code
```

## Architecture
```
lib/
  main.dart                    # entry point; also handles multi_window subprocess args
  files_repository.dart        # data layer: /Volumes/ scanning, indexed .txt I/O, path persistence
  event_bus.dart               # global EventBus singleton (cross-notifier events)
  providers.dart               # Riverpod provider declarations
  cubit/
    app_notifier.dart          # AppNotifier — search & scan logic (appProvider)
    app_state_models.dart      # AppState, DetailsLoaded, Detail, etc.
    device_notifier.dart       # DeviceNotifier — device list + StorageAction (deviceProvider)
    settings_notifier.dart     # SharedPreferences-backed settings
    statistics_notifier.dart
  main_page.dart               # primary search results UI
  filter_sidebar.dart          # left sidebar with file-type filter
  statistics_page.dart         # statistics view
  about_window.dart            # secondary window (multi_window)
  settings_window.dart         # secondary window (multi_window)

test/
  widget_test.dart             # single smoke test: App() renders without crash
```

**State management**: `flutter_riverpod` Notifier pattern (NOT flutter_bloc).  
**Cross-notifier communication**: global `EventBus` fires `SettingsChanged`, `RescanDevice(index)`, `DevicesChanged`.  
**Data persistence**: `shared_preferences` for settings; indexed file lists as plain `.txt` files on disk.

## Non-obvious conventions & quirks

### Multi-window
`main()` checks `args[0] == 'multi_window'` and runs either `AboutWindow` or
`SettingsWindow` as a separate Flutter app instance in a new OS window via
`desktop_multi_window`. All secondary windows work this way.

### Indexed data & device paths
- Scanned file paths are written one-per-line to
  `~/Documents/UsbFileFinder-Data/<deviceName>/<filetype>.txt`.
  Search reads these files directly — there is no database.
- Each device data directory may contain a hidden `.scan-path` file storing the
  full original scan path. This enables "Rescan Storage" to work for directories
  outside `/Volumes/`. Without it, `volumePathForIndex` falls back to
  `/Volumes/<deviceName>`.
- `FilesRepository.saveDevicePath()` writes `.scan-path`; called automatically
  by `AppNotifier.scanVolume()` on every scan.

### Rescan flow
`DeviceNotifier.menuAction(StorageAction.rescan, index)` fires `RescanDevice(index)`
on the event bus → `AppNotifier` receives it → calls `scanVolume(volumePath)`.
`scanVolume` checks `Directory.existsSync()` first; if missing it emits
`DetailsLoaded(message: 'Storage not found: ...')` which renders as a red banner
in `MainPage` (already present at `main_page.dart:91`).

### File types tracked
`text-files`, `audio-files`, `video-files`, `image-files`, `zip-files`,
`misc-files` — see `FilesRepository.fileTypes` and `buildExtensionMap()`.

### Ignored folders during scan
Hidden dirs (`.`-prefixed), `Backups.backupdb`, `Contents`, `BACKUP-ELLENS_MAC`
— see `AppNotifier._ignoredFolders` in `cubit/app_notifier.dart`.

### Miscellaneous
- `macos_window_utils` is used in `main.dart` but is a transitive dep of
  `macos_ui` — it does not appear directly in `pubspec.yaml`.
- `avoid_print` lint is **not** enabled — `print()` calls in production code are
  tolerated. Suppress other rules per-line with `// ignore: <rule_name>`.
- `DeviceNotifier.initialize()` registers a `DevicesChanged` listener each time
  it is called — calling it more than once will register duplicate listeners.
- No CI pipelines, no code generation, no build scripts beyond standard Flutter.
