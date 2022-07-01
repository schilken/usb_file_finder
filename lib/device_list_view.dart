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
                        final device = state.devices[index];
                        return CheckboxListTile(
                            tileColor: device.isMounted
                                ? Colors.green[100]
                                : Colors.transparent,
                            title: Text(device.name),
                            onChanged: (value) => context
                                .read<DeviceCubit>()
                                .toggleDevice(index, value),
                            value: device.isSelected,
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
                                          StorageAction.showInfo, index),
                                ),
                                MacosPulldownMenuItem(
                                  title: const Text('Eject Storage'),
                                  onTap: () => context
                                      .read<DeviceCubit>()
                                      .menuAction(StorageAction.eject, index),
                                ),
                                MacosPulldownMenuItem(
                                  title: const Text('Rescan Storage'),
                                  onTap: () => context
                                      .read<DeviceCubit>()
                                      .menuAction(StorageAction.rescan, index),
                                ),
                                MacosPulldownMenuItem(
                                  title: const Text('Remove Data'),
                                  onTap: () => context
                                      .read<DeviceCubit>()
                                      .menuAction(
                                          StorageAction.removeData, index),
                                ),
                              ],
                            ));
                      }),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${state.devices.length} Storages'),
                    MacosIconButton(
                      backgroundColor: Colors.transparent,
                      icon: const MacosIcon(
                        CupertinoIcons.refresh,
                      ),
                      shape: BoxShape.circle,
                      onPressed: () =>
                          context.read<DeviceCubit>().initialize(),
                    ),
                  ],
                ),
              ],
            );
          } else if (state is DeviceLoading) {
            return const Center(child: CupertinoActivityIndicator());
          } else {
            return const Text('No devices');
          }
        },
      ),
    );
  }
}
