import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:usb_file_finder/cubit/settings_cubit.dart';
import 'package:usb_file_finder/files_repository.dart';

part 'preferences_state.dart';

class PreferencesCubit extends Cubit<PreferencesState> {
  PreferencesCubit(
    SettingsCubit settingsCubit,
    this.filesRepository,
  ) : super(PreferencesInitial());

  final FilesRepository filesRepository;
}
