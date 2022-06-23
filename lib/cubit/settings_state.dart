// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_cubit.dart';

@immutable
abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  String examplesFolder;
  String packagesFolder;
  String flutterFolder;
  String myProjectsFolder;
  SettingsLoaded({
    required this.examplesFolder,
    required this.packagesFolder,
    required this.flutterFolder,
    required this.myProjectsFolder,
  });
}
