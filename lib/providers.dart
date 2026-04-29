import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usb_file_finder/files_repository.dart';

export 'package:usb_file_finder/cubit/app_notifier.dart'
    show
        appProvider,
        AppNotifier,
        AppState,
        AppInitial,
        DetailsLoading,
        DetailsLoaded,
        Detail;
export 'package:usb_file_finder/cubit/settings_notifier.dart'
    show settingsProvider, SettingsNotifier, SettingsState;

final filesRepositoryProvider = Provider<FilesRepository>((ref) {
  return FilesRepository();
});
