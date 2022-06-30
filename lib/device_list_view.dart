import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:usb_file_finder/cubit/device_cubit.dart';
import 'package:usb_file_finder/files_repository.dart';

class DeviceListView extends StatelessWidget {
  const DeviceListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeviceCubit>(
      create: (context) =>
          DeviceCubit(context.read<FilesRepository>())..initialize(),
      child: BlocBuilder<DeviceCubit, DeviceState>(
        builder: (context, state) {
          if (state is DeviceLoaded) {
            return ListView.builder(
                controller: ScrollController(),
                itemCount: state.devices.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(state.devices[index].name),
                    onChanged: (value) =>
                        context.read<DeviceCubit>().toggleDevice(index, value),
                    value: state.devices[index].isSelected,
                      secondary: MacosPulldownButton(
                        icon: CupertinoIcons.ellipsis_circle,
                        items: [
                          MacosPulldownMenuItem(
                            title: const Text('select all'),
                            onTap: () => debugPrint("select all"),
                          ),
                          MacosPulldownMenuItem(
                            title: const Text('select all others'),
                            onTap: () => debugPrint("select all others"),
                          ),
                          MacosPulldownMenuItem(
                            title: const Text('unselect all others'),
                            onTap: () => debugPrint("unselect all others"),
                          ),
                          const MacosPulldownMenuDivider(),
                          MacosPulldownMenuItem(
                            title: const Text('rescan'),
                            onTap: () => debugPrint("rescan"),
                          ),
                        ],
                      ) 
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
