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
    final devices = await filesRepository.readDeviceData();
    emit(
      DeviceLoaded(
        devices: devices,
        deviceCount: devices.length,
      ),
    );
    return this;
  }

  void toggleDevice(
    int index,
    bool? value,
  ) {
    final currentState = state as DeviceLoaded;
    emit(
      DeviceLoaded(
        devices: filesRepository.toggleDevice(index, value),
        deviceCount: currentState.deviceCount,
      ),
    );
  }
}
