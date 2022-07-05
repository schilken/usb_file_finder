import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:usb_file_finder/cubit/settings_cubit.dart';
import 'package:usb_file_finder/files_repository.dart';

part 'preferences_state.dart';

class PreferencesCubit extends Cubit<PreferencesState> {
  PreferencesCubit(
    this._settingsCubit,
    this._filesRepository,
  ) : super(PreferencesInitial());

  final FilesRepository _filesRepository;
  final SettingsCubit _settingsCubit;

  void load() async {
    emit(PreferencesLoading());
    emit(PreferencesLoaded(
      _settingsCubit.ignoredFolders,
      _settingsCubit.exclusionWords,
    ));
  }

  Future<void> addIgnoredFolder(String folder) async {
    await _settingsCubit.addIgnoredFolder(folder);
    load();
  }

  Future<void> removeIgnoredFolder(String folder) async {
    await _settingsCubit.removeIgnoredFolder(folder);
    load();
  }

  Future<void> addExclusionWord(String word) async {
    await _settingsCubit.addExclusionWord(word);
    load();
  }

  Future<void> removeExclusionWord(String word) async {
    await _settingsCubit.removeExclusionWord(word);
    load();
  }
}
