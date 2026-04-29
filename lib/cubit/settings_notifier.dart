import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_file_finder/event_bus.dart';

class SettingsState {
  const SettingsState({required this.fileTypeFilter});
  final String fileTypeFilter;
}

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  late SharedPreferences _prefs;

  @override
  Future<SettingsState> build() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _prefs = await SharedPreferences.getInstance();
    final state = _currentState;
    eventBus.fire(SettingsChanged(state.fileTypeFilter));
    return state;
  }

  SettingsState get _currentState => SettingsState(
        fileTypeFilter: _prefs.getString('fileTypeFilter') ?? 'Text Files',
      );

  String get fileTypeFilter =>
      _prefs.getString('fileTypeFilter') ?? 'Text Files';

  Future<void> setFileTypeFilter(String? value) async {
    if (value == null) return;
    await _prefs.setString('fileTypeFilter', value);
    final next = _currentState;
    state = AsyncData(next);
    eventBus.fire(SettingsChanged(next.fileTypeFilter));
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsState>(
    SettingsNotifier.new);
