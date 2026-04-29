import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usb_file_finder/event_bus.dart';
import 'package:usb_file_finder/files_repository.dart';
import 'package:usb_file_finder/providers.dart';

enum StorageAction {
  selectAll,
  selectAllOthers,
  unselectAllOthers,
  showInfo,
  rescan,
  removeData,
  eject,
}

abstract class DeviceState {
  const DeviceState();
}

class DeviceInitial extends DeviceState {
  const DeviceInitial();
}

class DeviceLoading extends DeviceState {
  const DeviceLoading();
}

class DeviceLoaded extends DeviceState {
  final List<StorageDetails> devices;
  final int deviceCount;
  const DeviceLoaded({required this.devices, required this.deviceCount});
}

class DeviceShowInfo extends DeviceState {
  final List<StorageDetails> devices;
  final int deviceCount;
  final StorageInfo storageInfo;
  final StorageDetails storageDetails;
  const DeviceShowInfo({
    required this.devices,
    required this.deviceCount,
    required this.storageInfo,
    required this.storageDetails,
  });
}

class DeviceNotifier extends Notifier<DeviceState> {
  late FilesRepository _filesRepository;

  @override
  DeviceState build() {
    _filesRepository = ref.read(filesRepositoryProvider);
    return const DeviceInitial();
  }

  Future<void> initialize() async {
    state = const DeviceLoading();
    await Future.delayed(const Duration(milliseconds: 1000));
    final devices = await _filesRepository.readDeviceData();
    state = DeviceLoaded(devices: devices, deviceCount: devices.length);
    eventBus.on<DevicesChanged>().listen((event) async {
      print('DeviceNotifier event: $event');
      final updated = await _filesRepository.readDeviceData();
      state = DeviceLoaded(devices: updated, deviceCount: updated.length);
    });
  }

  void toggleDevice(int index, bool? value) {
    final current = state as DeviceLoaded;
    state = DeviceLoaded(
      devices: _filesRepository.toggleDevice(index, value),
      deviceCount: current.deviceCount,
    );
  }

  void dismissInfo() {
    final current = state as DeviceShowInfo;
    state = DeviceLoaded(
      devices: current.devices,
      deviceCount: current.deviceCount,
    );
  }

  Future<void> menuAction(StorageAction action, int index) async {
    print('menuAction: $action');
    final s = state;
    final DeviceLoaded current;
    if (s is DeviceLoaded) {
      current = s;
    } else if (s is DeviceShowInfo) {
      current = DeviceLoaded(devices: s.devices, deviceCount: s.deviceCount);
    } else {
      return;
    }
    switch (action) {
      case StorageAction.selectAll:
      case StorageAction.selectAllOthers:
      case StorageAction.unselectAllOthers:
      case StorageAction.eject:
      case StorageAction.removeData:
        state = DeviceLoaded(
          devices: await _filesRepository.executeStorageAction(action, index),
          deviceCount: current.deviceCount,
        );
        break;
      case StorageAction.showInfo:
        final details = _filesRepository.storageDetailsForIndex(index);
        final info = await _filesRepository.createStorageInfoForDevice(details);
        state = DeviceShowInfo(
          devices: current.devices,
          deviceCount: current.deviceCount,
          storageInfo: info,
          storageDetails: details,
        );
        break;
      case StorageAction.rescan:
        eventBus.fire(RescanDevice(index));
        break;
    }
  }
}

final deviceProvider =
    NotifierProvider<DeviceNotifier, DeviceState>(DeviceNotifier.new);
