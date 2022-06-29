part of 'device_cubit.dart';

class Device {
  final String name;
  final int fileCount;
  final bool isSelected;

  Device(this.name, this.fileCount, this.isSelected);
}

abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object> get props => [];
}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DeviceLoaded extends DeviceState {
  final List<Device> devices;
  final int deviceCount;

  const DeviceLoaded({
    required this.devices,
    required this.deviceCount,
  });
  @override
  List<Object> get props => [devices, deviceCount];
}
