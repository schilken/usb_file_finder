import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'device_state.dart';

class DeviceCubit extends Cubit<DeviceState> {
  DeviceCubit() : super(DeviceInitial());

  Future<DeviceCubit> initialize() async {
    emit(DeviceLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    emit(
      DeviceLoaded(
        devices: [
          Device('128GB', 1, false),
          Device('XXXGB', 1, true),
        ],
        deviceCount: 2,
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
            return Device(
              device.name,
              device.fileCount,
              value ?? !device.isSelected,
            );
          }
          return device;
        }).toList(),
        deviceCount: currentState.deviceCount,
      ),
    );
  }
}
