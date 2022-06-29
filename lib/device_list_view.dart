import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usb_file_finder/cubit/device_cubit.dart';

class DeviceListView extends StatelessWidget {
  const DeviceListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeviceCubit>(
      create: (context) => DeviceCubit()..initialize(),
      child: BlocBuilder<DeviceCubit, DeviceState>(
        builder: (context, state) {
          if (state is DeviceLoaded) {
            return ListView.builder(
                itemCount: state.devices.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(state.devices[index].name),
                    onChanged: (value) =>
                        context.read<DeviceCubit>().toggleDevice(value, index),
                    value: state.devices[index].isSelected,
                  );
                });
          } else if (state is DeviceLoading) {
            return const CircularProgressIndicator();
          } else {
            return const Text('No devices');
          }
        },
      ),
    );
  }
}
