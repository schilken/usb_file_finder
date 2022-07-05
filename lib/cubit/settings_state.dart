// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_cubit.dart';

@immutable
abstract class SettingsState extends Equatable {}

class SettingsInitial extends SettingsState {
  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsState {
  String fileTypeFilter;
  bool showHiddenFiles;
  bool searchInFilename;
  bool searchInFoldername;
  final List<String> ignoredFolders;
  final List<String> exclusionWords;

  SettingsLoaded({
    required this.fileTypeFilter,
    required this.showHiddenFiles,
    required this.searchInFilename,
    required this.searchInFoldername,
    required this.ignoredFolders,
    required this.exclusionWords,
  });

  @override
  List<Object?> get props => [
        fileTypeFilter,
        showHiddenFiles,
        searchInFilename,
        searchInFoldername,
        ignoredFolders,
        exclusionWords,
      ];
}
