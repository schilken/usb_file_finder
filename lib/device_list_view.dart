import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:usb_file_finder/cubit/device_notifier.dart';

class DeviceListView extends ConsumerStatefulWidget {
  const DeviceListView({super.key});

  @override
  ConsumerState<DeviceListView> createState() => _DeviceListViewState();
}

class _DeviceListViewState extends ConsumerState<DeviceListView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(deviceProvider.notifier).initialize());
  }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceProvider);
    if (deviceState is DeviceLoaded) {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: ScrollController(),
              itemCount: deviceState.devices.length,
              itemBuilder: (context, index) {
                final device = deviceState.devices[index];
                return CheckboxListTile(
                  tileColor:
                      device.isMounted ? Colors.green[100] : Colors.transparent,
                  title: Text(device.name),
                  onChanged: (value) => ref
                      .read(deviceProvider.notifier)
                      .toggleDevice(index, value),
                  value: device.isSelected,
                  secondary: MacosPulldownButton(
                    icon: CupertinoIcons.ellipsis_circle,
                    items: [
                      MacosPulldownMenuItem(
                        title: const Text('Select all'),
                        onTap: () => ref
                            .read(deviceProvider.notifier)
                            .menuAction(StorageAction.selectAll, index),
                      ),
                      MacosPulldownMenuItem(
                        title: const Text('Select all others'),
                        onTap: () => ref
                            .read(deviceProvider.notifier)
                            .menuAction(StorageAction.selectAllOthers, index),
                      ),
                      MacosPulldownMenuItem(
                        title: const Text('Unselect all others'),
                        onTap: () => ref
                            .read(deviceProvider.notifier)
                            .menuAction(StorageAction.unselectAllOthers, index),
                      ),
                      const MacosPulldownMenuDivider(),
                      MacosPulldownMenuItem(
                        title: const Text('Show Details'),
                        onTap: () => ref
                            .read(deviceProvider.notifier)
                            .menuAction(StorageAction.showInfo, index),
                      ),
                      MacosPulldownMenuItem(
                        title: const Text('Eject Storage'),
                        onTap: () => ref
                            .read(deviceProvider.notifier)
                            .menuAction(StorageAction.eject, index),
                      ),
                      MacosPulldownMenuItem(
                        title: const Text('Rescan Storage'),
                        onTap: () => ref
                            .read(deviceProvider.notifier)
                            .menuAction(StorageAction.rescan, index),
                      ),
                      MacosPulldownMenuItem(
                        title: const Text('Remove Data'),
                        onTap: () => ref
                            .read(deviceProvider.notifier)
                            .menuAction(StorageAction.removeData, index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${deviceState.devices.length} Storages'),
              MacosIconButton(
                backgroundColor: Colors.transparent,
                icon: const MacosIcon(CupertinoIcons.refresh),
                shape: BoxShape.circle,
                onPressed: () => ref.read(deviceProvider.notifier).initialize(),
              ),
            ],
          ),
        ],
      );
    } else if (deviceState is DeviceLoading) {
      return const Center(child: CupertinoActivityIndicator());
    } else {
      return const Text('No devices');
    }
  }
}
