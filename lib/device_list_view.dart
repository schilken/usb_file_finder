import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:usb_file_finder/cubit/device_notifier.dart';
import 'package:usb_file_finder/files_repository.dart';

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

    if (deviceState is DeviceShowInfo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showStorageInfoDialog(
            context, deviceState.storageInfo, deviceState.storageDetails);
      });
    }

    final devices = deviceState is DeviceLoaded
        ? deviceState.devices
        : deviceState is DeviceShowInfo
            ? deviceState.devices
            : null;
    final deviceCount = deviceState is DeviceLoaded
        ? deviceState.devices.length
        : deviceState is DeviceShowInfo
            ? deviceState.devices.length
            : null;

    if (devices != null) {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: ScrollController(),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
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
              Text('${deviceCount ?? 0} Storages'),
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

  void _showStorageInfoDialog(
      BuildContext context, StorageInfo info, StorageDetails details) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: Text(info.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow('Name', details.name),
              _infoRow('Path', details.fullPath),
              _infoRow('Status', info.isMounted ? 'Mounted' : 'Not mounted'),
              _infoRow('Total files', '${info.totalFileCount}'),
              const Divider(),
              ...info.fileCountMap.entries.map(
                (e) => _infoRow(e.key, '${e.value}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(deviceProvider.notifier).dismissInfo();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    ).then((_) {
      // If dismissed via barrier tap the state still needs to be reset
      if (ref.read(deviceProvider) is DeviceShowInfo) {
        ref.read(deviceProvider.notifier).dismissInfo();
      }
    });
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          Text(value),
        ],
      ),
    );
  }
}
