# AGENTS.md

## What this app does
`usb_file_finder` is a macOS-only Flutter desktop app. It scans USB/external
volumes, indexes files by type into plain-text files stored in
`~/Documents/UsbFileFinder-Data/<volumeName>/<filetype>.txt`, and lets the
user search that index by keyword with filtering options. UI uses `macos_ui`
to match native AppKit appearance.

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
  main.dart              # entry point; also handles multi_window subprocess args
  files_repository.dart  # data layer: /Volumes/ scanning, indexed .txt I/O
  event_bus.dart         # global EventBus singleton (cross-cubit events)
  cubit/
    app_cubit/state      # search & scan logic
    device_cubit/state   # device list management
    settings_cubit/state # SharedPreferences-backed settings
    statistics_cubit/state
  main_page.dart         # primary search results UI
  filter_sidebar.dart    # left sidebar with file-type filter
  statistics_page.dart   # package statistics view
  about_window.dart / settings_window.dart  # secondary windows (multi_window)

test/
  widget_test.dart       # single smoke test: App() renders without crash
```

**State management**: `flutter_bloc` Cubit pattern + `equatable` for state equality.  
**Cross-cubit communication**: global `EventBus` (fires `SettingsChanged`, `RescanDevice`, `DevicesChanged`).  
**Data persistence**: `shared_preferences` for settings; indexed file lists as plain `.txt` files on disk.

## Non-obvious conventions & quirks
- **Multi-window pattern**: `main()` checks `args[0] == 'multi_window'` and
  runs either `AboutWindow` or `SettingsWindow` as a separate Flutter app
  instance in a new OS window. All secondary windows work this way.
- **Indexed data**: scanned file paths are written one-per-line to
  `~/Documents/UsbFileFinder-Data/<volumeName>/<filetype>.txt`. Search reads
  these files directly — there is no database.
- **File types tracked**: `text-files`, `audio-files`, `video-files`,
  `image-files`, `zip-files`, `misc-files` (see `FilesRepository.fileTypes`).
- **Ignored folders during scan**: hidden dirs (`.`-prefixed),
  `Backups.backupdb`, `Contents`, `BACKUP-ELLENS_MAC`
  (see `AppCubit._ignoredFolders`).
- `macos_window_utils` is used in `main.dart` but is a transitive dep of
  `macos_ui` — it does not appear directly in `pubspec.yaml`.
- `avoid_print` is **not** enabled — `print()` calls in production code are
  tolerated. Suppress other rules per-line with `// ignore: <rule_name>`.
- No CI pipelines, no code generation, no build scripts beyond standard Flutter.
