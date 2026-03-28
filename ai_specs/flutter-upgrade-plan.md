## Overview

Upgrade `usb_file_finder` from Dart 2.17 / Flutter 3.x to Flutter 3.35.4 (Dart 3.9.2). Major version bump — SDK constraint, all dependencies, and Dart 3 syntax fixes required.

## Context

- **Structure**: flat `lib/` with `cubit/` subfolder (layer-first)
- **State management**: flutter_bloc + equatable (Cubit pattern)
- **Platform**: macOS desktop (macos_ui, desktop_multi_window)
- **Reference files**: `lib/main.dart`, `lib/cubit/app_cubit.dart`, `lib/cubit/device_cubit.dart`, `lib/files_repository.dart`
- **Key risk packages**: `macos_ui` (1.x→2.x major), `desktop_multi_window`, `intl` (0.17→0.19)

## Plan

### Phase 1: pubspec.yaml + SDK constraint

- **Goal**: Get project resolving dependencies on Dart 3.9.2
- [ ] `pubspec.yaml` — change SDK to `sdk: ">=3.0.0 <4.0.0"`
- [ ] `pubspec.yaml` — remove `meta: ^1.7.0` (included in Dart SDK)
- [ ] `pubspec.yaml` — replace `flutter_lints: ^2.0.1` with `flutter_lints: ^4.0.0` (or `lints: ^4.0.0`)
- [ ] `pubspec.yaml` — update all deps to latest compatible versions:
  - `flutter_bloc: ^9.1.0`, `bloc: ^9.0.0`, `equatable: ^2.0.7`
  - `provider: ^6.1.2`
  - `macos_ui: ^2.1.8` (check latest; major breaking changes from 1.x)
  - `desktop_multi_window: ^0.2.0` (check latest)
  - `file_picker: ^8.0.0+1` (check latest)
  - `flutter_hooks: ^0.20.5`
  - `flutter_svg: ^2.0.16`
  - `shared_preferences: ^2.5.0`
  - `yaml: ^3.1.2`
  - `path: ^1.9.1`
  - `path_provider: ^2.1.5`
  - `intl: ^0.19.0`
  - `event_bus: ^2.0.0` (likely compatible)
  - `collection: ^1.19.0`
  - `cupertino_icons: ^1.0.8`
- [ ] Run `flutter pub get` — resolve, fix version conflicts iteratively
- [ ] Run `dart pub outdated` to verify all resolved

### Phase 2: Fix Dart 3 breaking changes + API breaks

- **Goal**: `flutter analyze` passes with zero errors
- [ ] `lib/cubit/device_cubit.dart:62-81` — `switch` on `StorageAction` enum: Dart 3 requires exhaustive switch; add `default` or restructure to exhaustive pattern
- [ ] `lib/files_repository.dart:173-211` — same `switch` on `StorageAction`; fix exhaustiveness
- [ ] `lib/cubit/app_state.dart` — verify `@immutable` / `Equatable` patterns still valid with Dart 3
- [ ] `lib/main.dart` — `macos_ui` 2.x API changes: verify `MacosApp`, `MacosWindow`, `Sidebar`, `SidebarItems`, `MacosIcon`, `MacosListTile` signatures
- [ ] `lib/filter_sidebar.dart` — verify `MacosPopupButton` / `MacosPopupMenuItem` still exist in macos_ui 2.x
- [ ] `lib/main_page.dart` — verify `MacosScaffold`, `ContentArea`, `MacosIconButton`, `MacosAlertDialog`, `showMacosAlertDialog`, `PushButton`, `ButtonSize` APIs
- [ ] `lib/get_custom_toolbar.dart` — verify `MacosToolbar`, `ToolBarIconButton`, `MacosWindowScope.toggleSidebar()`
- [ ] `lib/toolbar_widget_toggle.dart` — verify `MacosIconButton` API
- [ ] `lib/macos_prompt_dialog.dart` — verify `MacosTheme.brightnessOf()`, `MacosTheme.of()` API
- [ ] `lib/about_window.dart` — verify `MacosApp`, `MacosWindow` API
- [ ] `lib/cubit/settings_cubit.dart` — `SharedPreferences.getInstance()` already async, verify no change
- [ ] `analysis_options.yaml` — update `include: package:flutter_lints/flutter.yaml` if package name changed
- [ ] Remove any unused imports flagged by analyzer
- [ ] Fix all `flutter analyze` warnings/errors

### Phase 3: Verify

- **Goal**: Project builds and analyzes clean
- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` — existing test passes (update `test/widget_test.dart` if needed)
- [ ] `flutter build macos` — confirm macOS build succeeds (if applicable)

## Risks / Out of scope

- **Risks**: `macos_ui` 2.x may have significant API renames/removals — may require rewriting sidebar, toolbar, dialog code. `desktop_multi_window` may have breaking changes. Actual latest package versions on pub.dev may differ from estimates above — check each during Phase 1.
- **Out of scope**: Feature changes, refactoring to Dart 3 patterns (records, sealed classes), migrating away from `flutter_bloc`. Only minimum changes to compile + analyze clean on Flutter 3.35.4.
