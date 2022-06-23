import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial());
  late SharedPreferences _prefs;
  Future<SettingsCubit> initialize() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  String get examplesFolder =>
      _prefs.getString('examplesFolder') ??
      '/Users/aschilken/flutterdev/examples';
}
