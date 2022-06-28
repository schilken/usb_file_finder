import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:usb_file_finder/cubit/settings_cubit.dart';

class FilterSettings extends StatelessWidget {
  const FilterSettings({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Filter Files',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            MacosPopupButton<String>(
              value: context.read<SettingsCubit>().fileTypeFilter,
              onChanged: (String? value) async {
                await context.read<SettingsCubit>().setFileTypeFilter(value);
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
            SizedBox(
              height: 500,
              child: Material(
                child: ListView(
                  controller: ScrollController(),
                  children: [
                    CheckboxListTile(
                        title: const Text('128GB'),
                        value: true,
                        onChanged: (_) {}),
                    CheckboxListTile(
                        title: const Text('WD1TB'),
                        value: true,
                        onChanged: (_) {}),
                    CheckboxListTile(
                        title: const Text('GE5TB'),
                        value: true,
                        onChanged: (_) {}),
                    CheckboxListTile(
                        title: const Text('128GB'),
                        value: true,
                        onChanged: (_) {}),
                    CheckboxListTile(
                        title: const Text('WD1TB'),
                        value: true,
                        onChanged: (_) {}),
                    CheckboxListTile(
                        title: const Text('GE5TB'),
                        value: true,
                        onChanged: (_) {}),
                    CheckboxListTile(
                        title: const Text('128GB'),
                        value: true,
                        onChanged: (_) {}),
                    CheckboxListTile(
                        title: const Text('WD1TB'),
                        value: true,
                        onChanged: (_) {}),
                    CheckboxListTile(
                        title: const Text('GE5TB'),
                        value: true,
                        onChanged: (_) {}),
                    CheckboxListTile(
                        title: const Text('128GB'),
                        value: true,
                        onChanged: (_) {}),
                    CheckboxListTile(
                        title: const Text('WD1TB'),
                        value: true,
                        onChanged: (_) {}),
                    CheckboxListTile(
                        title: const Text('GE5TB'),
                        value: true,
                        onChanged: (_) {}),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Text('Filter Lines', style: TextStyle(fontWeight: FontWeight.bold)),
            // SizedBox(height: 16),
            // MacosPopupButton<String>(
            //   value: context.read<SettingsCubit>().lineFilter,
            //   onChanged: (String? newValue) async {
            //     await context.read<SettingsCubit>().setLineFilter(newValue);
            //   },
            //   items: <String>['Only First Line', 'First Two Lines', 'All Lines']
            //       .map<MacosPopupMenuItem<String>>((String value) {
            //     return MacosPopupMenuItem<String>(
            //       value: value,
            //       child: Text(value),
            //     );
            //   }).toList(),
            // ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}
