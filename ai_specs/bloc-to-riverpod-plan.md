# Plan: Replace flutter_bloc / bloc with Riverpod

## Overview

Migrate all 4 Cubits + their states to Riverpod `StateNotifier`/`AsyncNotifier` providers.  
Remove `flutter_bloc`, `bloc`, `equatable`; add `flutter_riverpod`.

## Context

- **Structure**: layer-first (`lib/cubit/`, UI widgets in `lib/`)
- **State management**: `flutter_bloc` Cubit pattern; `RepositoryProvider` for `FilesRepository`; `provider` pkg also present (unused directly)
- **Reference implementations**: `lib/cubit/app_cubit.dart`, `lib/cubit/settings_cubit.dart`, `lib/cubit/device_cubit.dart`, `lib/cubit/statistics_cubit.dart`
- **Assumptions/Gaps**:
  - `equatable` used only for Bloc state equality → can be removed after migration
  - `provider` pkg in pubspec appears unused in app code; leave unless confirmed needed
  - `event_bus` cross-cubit communication kept as-is (orthogonal to state mgmt)
  - `RepositoryProvider` (flutter_bloc) wraps `FilesRepository` → replaced with a Riverpod provider
  - Secondary windows (`AboutWindow`, `SettingsWindow`) use no Bloc — no changes needed there
  - `flutter_hooks` stays; compatible with riverpod via `hooks_riverpod` (optional — use `flutter_riverpod` only unless hooks wanted)

## Plan

### Phase 1: Add Riverpod, scaffold FilesRepository provider

- **Goal**: Riverpod wired into app; `FilesRepository` injectable via provider; app still builds
- [x] `pubspec.yaml` — add `flutter_riverpod: ^2.x`; keep `flutter_bloc`/`bloc` for now (installed 3.3.1)
- [x] `lib/main.dart` — wrap root with `ProviderScope`; keep existing `MultiBlocProvider` in parallel
- [x] `lib/providers.dart` (new) — define `filesRepositoryProvider` (`Provider<FilesRepository>`)
- [x] Verify: `flutter analyze` && `flutter test` (analyze: 0 errors; test: pre-existing PlatformProvidedMenuItem failure unrelated to this change)

### Phase 2: Migrate SettingsCubit → SettingsNotifier

- **Goal**: `SettingsCubit` replaced by `StateNotifier`; `filter_sidebar.dart` reads from Riverpod
- [x] `lib/cubit/settings_notifier.dart` (new) — `SettingsState` as plain class (no Equatable), `SettingsNotifier extends AsyncNotifier<SettingsState>`, mirror `initialize()` / `setFileTypeFilter()` / `emitSettingsLoaded()` logic
- [x] `lib/providers.dart` — add `settingsProvider` (`AsyncNotifierProvider<SettingsNotifier, SettingsState>`); exports re-exported from notifier file
- [x] `lib/filter_sidebar.dart` — replace `BlocBuilder<SettingsCubit>` + `context.read<SettingsCubit>` with `ref.watch(settingsProvider)` / `ref.read(settingsProvider.notifier)`; converted to `ConsumerWidget`
- [ ] `lib/main.dart` — remove `BlocProvider.value(value: snapshot.data!)` for SettingsCubit; remove `FutureBuilder<SettingsCubit>` wrapper; use `settingsProvider` initialization instead — **deferred to Phase 3** (AppCubit still depends on SettingsCubit)
- [ ] Delete `lib/cubit/settings_cubit.dart` and `lib/cubit/settings_state.dart` once unused — **deferred: still needed by AppCubit until Phase 3**
- [x] Verify: `flutter analyze` (0 errors) && `flutter test` (pre-existing failure only)

### Phase 3: Migrate AppCubit → AppNotifier

- **Goal**: `AppCubit` replaced; all UI consumers updated
- [x] `lib/cubit/app_notifier.dart` (new) — `AppNotifier extends Notifier<AppState>`; state classes extracted to `app_state_models.dart`; all methods mirrored
- [x] `lib/providers.dart` — add `appProvider` (`NotifierProvider`); exports `AppNotifier`, state types
- [x] `lib/main_page.dart` — replaced `BlocBuilder<AppCubit>` + `context.read<AppCubit>` with `ref.watch(appProvider)` / `ref.read(appProvider.notifier)`; converted to `ConsumerWidget`
- [x] `lib/get_custom_toolbar.dart` — replaced all `context.read<AppCubit>()` with `ref.read(appProvider.notifier)`; signature updated to `(BuildContext, WidgetRef)`
- [x] `lib/detail_tile.dart` — replaced `context.read<AppCubit>()` with `ref.read(appProvider.notifier)`; `NameWithOpenInEditor` → `ConsumerWidget`
- [x] `lib/main.dart` — removed `BlocProvider` for `AppCubit`, removed `FutureBuilder<SettingsCubit>`, removed `RepositoryProvider`; `App` is now a plain `StatelessWidget`
- [x] Delete `lib/cubit/app_cubit.dart` + `lib/cubit/app_state.dart` — deleted
- [x] Delete `lib/cubit/settings_cubit.dart` + `lib/cubit/settings_state.dart` — deleted (deferred from Phase 2)
- [x] `lib/statistics_page.dart` — converted to `ConsumerWidget` to pass `ref` to `getCustomToolBar` (full migration deferred to Phase 4)
- [x] Verify: `flutter analyze` (0 errors) && `flutter test` (pre-existing failure only)

### Phase 4: Migrate DeviceCubit + StatisticsCubit

- **Goal**: remaining cubits replaced; flutter_bloc fully removed
- [ ] `lib/cubit/device_notifier.dart` (new) — `DeviceNotifier extends StateNotifier<DeviceState>`; mirror `initialize()`, `toggleDevice()`, `menuAction()`
- [ ] `lib/cubit/statistics_notifier.dart` (new) — `StatisticsNotifier extends StateNotifier<StatisticsState>`; mirror `load()`
- [ ] `lib/providers.dart` — add `deviceProvider`, `statisticsProvider`
- [ ] `lib/device_list_view.dart` — replace `BlocProvider<DeviceCubit>` + `BlocBuilder` with `ref.watch(deviceProvider)` / `ref.read(deviceProvider.notifier)`; `ConsumerWidget`
- [ ] `lib/statistics_page.dart` — replace `BlocProvider<StatisticsCubit>` + `BlocBuilder` with Riverpod equivalents; `ConsumerWidget`
- [ ] `pubspec.yaml` — remove `flutter_bloc`, `bloc`; remove `equatable` if no longer used elsewhere; remove `provider` if unused
- [ ] Delete all remaining cubit files; delete `lib/cubit/` directory if empty
- [ ] Verify: `flutter analyze` && `flutter test`

## Risks / Out of scope

- **Risks**:
  - `SettingsCubit.initialize()` is async with 1s delay + SharedPreferences; Riverpod `AsyncNotifier` or `FutureProvider` needed — splash/loading UX must be preserved
  - `AppCubit` subscribes to `eventBus` in constructor — notifier init timing must replicate this; if `StateNotifier` is auto-disposed, subscriptions leak
  - `DeviceCubit.initialize()` also called lazily from UI — provider must not auto-dispose between navigations
- **Out of scope**: replacing `event_bus` with Riverpod streams; migrating secondary windows; adding tests beyond smoke test
