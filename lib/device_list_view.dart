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
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      controller: ScrollController(),
                      itemCount: state.devices.length,
                      itemBuilder: (context, index) {
                        return CheckboxListTile(
                            title: Text(state.devices[index].name),
                            onChanged: (value) => context
                                .read<DeviceCubit>()
                                .toggleDevice(index, value),
                            value: state.devices[index].isSelected,
                            secondary: MacosPulldownButton(
                              icon: CupertinoIcons.ellipsis_circle,
                              items: [
                                MacosPulldownMenuItem(
                                  title: const Text('Select all'),
                                  onTap: () => context
                                      .read<DeviceCubit>()
                                      .menuAction(
                                          StorageAction.selectAll, index),
                                ),
                                MacosPulldownMenuItem(
                                  title: const Text('Select all others'),
                                  onTap: () => context
                                      .read<DeviceCubit>()
                                      .menuAction(
                                          StorageAction.selectAllOthers, index),
                                ),
                                MacosPulldownMenuItem(
                                  title: const Text('Unselect all others'),
                                  onTap: () => context
                                      .read<DeviceCubit>()
                                      .menuAction(
                                          StorageAction.unselectAllOthers,
                                          index),
                                ),
                                const MacosPulldownMenuDivider(),
                                MacosPulldownMenuItem(
                                  title: const Text('Show Details'),
                                  onTap: () => context
                                      .read<DeviceCubit>()
                                      .menuAction(
                                          StorageAction.showDetails, index),
                                ),
                                MacosPulldownMenuItem(
                                  title: const Text('Rescan'),
                                  onTap: () => context
                                      .read<DeviceCubit>()
                                      .menuAction(StorageAction.rescan, index),
                                ),
                              ],
                            ));
                      }),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('5 Storages'),
                    MacosIconButton(
                      backgroundColor: Colors.transparent,
                      icon: MacosIcon(
                        size: 32,
                        CupertinoIcons.refresh,
                      ),
                      shape: BoxShape.circle,
                      onPressed: () =>
                          context.read<DeviceCubit>().refreshDevices(),
                    ),
                  ],
                ),
              ],
            );
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
