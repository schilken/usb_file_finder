import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_file_finder/event_bus.dart';

part 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(SettingsInitial()) {
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

  Future<FilterCubit> initialize() async {
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
    final settingsLoaded = FilterLoaded(
      fileTypeFilter: fileTypeFilter,
      showHiddenFiles: getSearchOption('showHiddenFiles'),
      searchInFilename: getSearchOption('searchInFilename'),
      searchInFoldername: getSearchOption('searchInFoldername'),
      ignoredFolders: ignoredFolders,
      exclusionWords: exclusionWords,
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

  List<String> get ignoredFolders {
    final ignoredFolders = _prefs.getStringList('ignoredFolders') ?? [];
    return ignoredFolders;
  }

  List<String> get exclusionWords {
    final exclusionWords = _prefs.getStringList('exclusionWords') ?? [];
    return exclusionWords;
  }

  Future<void> addIgnoredFolder(String folder) async {
    final ignoredFolders = _prefs.getStringList('ignoredFolders') ?? [];
    ignoredFolders.add(folder);
    await _prefs.setStringList('ignoredFolders', ignoredFolders);
    emitSettingsLoaded();
  }

  Future<void> removeIgnoredFolder(String folder) async {
    final ignoredFolders = _prefs.getStringList('ignoredFolders') ?? [];
    ignoredFolders.remove(folder);
    await _prefs.setStringList('ignoredFolders', ignoredFolders);
    emitSettingsLoaded();
  }

  Future<void> addExclusionWord(String exclusionWord) async {
    final exclusionWords = _prefs.getStringList('exclusionWords') ?? [];
    exclusionWords.add(exclusionWord);
    await _prefs.setStringList('exclusionWords', exclusionWords);
    emitSettingsLoaded();
  }

  Future<void> removeExclusionWord(String exclusionWord) async {
    final exclusionWords = _prefs.getStringList('exclusionWords') ?? [];
    exclusionWords.remove(exclusionWord);
    await _prefs.setStringList('exclusionWords', exclusionWords);
    emitSettingsLoaded();
  }
}
