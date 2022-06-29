import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:usb_file_finder/files_repository.dart';

part 'device_state.dart';

class DeviceCubit extends Cubit<DeviceState> {
  DeviceCubit(this.filesRepository) : super(DeviceInitial());

  final FilesRepository filesRepository;

  Future<DeviceCubit> initialize() async {
    emit(DeviceLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    await filesRepository.readDeviceData();
    emit(
      DeviceLoaded(
        devices: filesRepository.devices,
        deviceCount: filesRepository.devices.length,
      ),
    );
    return this;
  }

  void toggleDevice(bool? value, int index) {
    final currentState = state as DeviceLoaded;
    emit(
      DeviceLoaded(
        devices: currentState.devices.map((device) {
          if (device.name == currentState.devices[index].name) {
            return StorageDetails(
              name: device.name,
              fileCount: device.fileCount,
              isSelected: value ?? !device.isSelected,
            );
          }
          return device;
        }).toList(),
        deviceCount: currentState.deviceCount,
      ),
    );
  }
}
