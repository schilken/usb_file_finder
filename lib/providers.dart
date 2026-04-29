import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usb_file_finder/files_repository.dart';

export 'package:usb_file_finder/providers/app_notifier.dart'
    show
        appProvider,
        AppNotifier,
        AppState,
        AppInitial,
        DetailsLoading,
        DetailsLoaded,
        Detail;
export 'package:usb_file_finder/providers/device_notifier.dart'
    show
        deviceProvider,
        DeviceNotifier,
        DeviceState,
        DeviceInitial,
        DeviceLoading,
        DeviceLoaded,
        StorageAction;
export 'package:usb_file_finder/providers/settings_notifier.dart'
    show settingsProvider, SettingsNotifier, SettingsState;
export 'package:usb_file_finder/providers/statistics_notifier.dart'
    show
        statisticsProvider,
        StatisticsNotifier,
        StatisticsState,
        StatisticsInitial,
        StatisticsLoading,
        StatisticsLoaded,
        Frequency;

final filesRepositoryProvider = Provider<FilesRepository>((ref) {
  return FilesRepository();
});
