import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:usb_file_finder/providers/settings_notifier.dart';
import 'package:usb_file_finder/device_list_view.dart';

class FilterSidebar extends ConsumerWidget {
  const FilterSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final currentFilter = settingsAsync.value?.fileTypeFilter ?? 'Text Files';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Filter Files',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        MacosPopupButton<String>(
          value: currentFilter,
          onChanged: (String? value) async {
            await ref.read(settingsProvider.notifier).setFileTypeFilter(value);
          },
          items: <String>[
            'Text Files',
            'Audio Files',
            'Video Files',
            'Image Files',
            'Misc Files',
            'ZIP Files',
          ].map<MacosPopupMenuItem<String>>((String value) {
            return MacosPopupMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const SizedBox(
          height: 600,
          width: 220,
          child: Material(
            child: DeviceListView(),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
