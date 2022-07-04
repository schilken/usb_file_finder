import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_file_finder/event_bus.dart';

part 'settings_state.dart';
 
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial()) {
    print('create SettingsCubit');
    eventBus.on<SettingsTrigger>().listen((event) async {
      print('SettingsTrigger received');
      emitSettingsLoaded();
    });

  }
  late SharedPreferences _prefs;

  final allFileTypes = <String>[
    'Text Files',
    'Audio Files',
    'Video Files',
    'Image Files',
    'Misc Files',
    'ZIP Files',
    'Dart Files',
  ];

  get fileTypeFilter => _prefs.getString('fileTypeFilter') ?? 'Text Files';

  Future<SettingsCubit> initialize() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _prefs = await SharedPreferences.getInstance();
    emitSettingsLoaded();
    return this;
  }

  Future<void> setFileTypeFilter(value) async {
    await _prefs.setString('fileTypeFilter', value);
    emitSettingsLoaded();
  }

  void emitSettingsLoaded() {
    final settingsLoaded = SettingsLoaded(
      fileTypeFilter: fileTypeFilter,
      showHiddenFiles: getSearchOption('showHiddenFiles'),
      searchInFilename: getSearchOption('searchInFilename'),
      searchInFoldername: getSearchOption('searchInFoldername'),
    );
    emit(settingsLoaded);
    eventBus.fire(settingsLoaded);
  }

  Future<void> toggleSearchOption(String option, bool value) async {
    await _prefs.setBool(option, value);
    emitSettingsLoaded();
  }

  bool getSearchOption(String option) {
    return _prefs.getBool(option) ?? false;
  }

}
