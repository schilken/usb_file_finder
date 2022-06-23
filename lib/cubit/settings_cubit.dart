import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial());
  late SharedPreferences _prefs;

  get lineFilter => _prefs.getString('lineFilter') ?? 'All Lines';

  get testFileFilter => _prefs.getString('testFileFilter') ?? 'All Files';

  get exampleFileFilter => _prefs.getString('exampleFileFilter') ?? 'All Files';

  Future<SettingsCubit> initialize() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  String get examplesFolder =>
      _prefs.getString('examplesFolder') ??
      '/Users/aschilken/flutterdev/examples';

  String get packagesFolder =>
      _prefs.getString('packagesFolder') ??
      '/Users/aschilken/.pub-cache/hosted/pub.dartlang.org';

  String get flutterSourceFolder =>
      _prefs.getString('flutterSourceFolder') ??
      '/Users/aschilken/flutterdev/flutter';

  Future<void> setTestFileFilter(value) async {
    await _prefs.setString('testFileFilter', value);
    emit(SettingsLoaded(
        examplesFolder: examplesFolder,
        flutterFolder: flutterSourceFolder,
        myProjectsFolder: '',
        packagesFolder: packagesFolder));
  }

  Future<void> setExampleFileFilter(value) async {
    await _prefs.setString('exampleFileFilter', value);
    emit(SettingsLoaded(
        examplesFolder: examplesFolder,
        flutterFolder: flutterSourceFolder,
        myProjectsFolder: '',
        packagesFolder: packagesFolder));
  }

  Future<void> setLineFilter(value) async {
    await _prefs.setString('lineFilter', value);
    emit(SettingsLoaded(
        examplesFolder: examplesFolder,
        flutterFolder: flutterSourceFolder,
        myProjectsFolder: '',
        packagesFolder: packagesFolder));
  }

}
