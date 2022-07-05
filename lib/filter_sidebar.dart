import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:usb_file_finder/cubit/settings_cubit.dart';
import 'package:usb_file_finder/device_list_view.dart';
import 'package:usb_file_finder/macos_checkbox_list_tile.dart';

class FilterSidebar extends StatelessWidget {
  const FilterSidebar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        print('FilterSidebar builder: ${state}');

        if (state is SettingsLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter Files',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              MacosPopupButton<String>(
                value: context.read<SettingsCubit>().fileTypeFilter,
                onChanged: (String? value) async {
                  await context.read<SettingsCubit>().setFileTypeFilter(value);
                },
                items: context
                    .read<SettingsCubit>()
                    .allFileTypes
                    .map<MacosPopupMenuItem<String>>((String value) {
                  return MacosPopupMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 4, 0),
                child: MacosCheckBoxListTile(
                  title: Text('Include Hidden Folders'),
                  onChanged: (value) => context
                      .read<SettingsCubit>()
                      .toggleSearchOption('showHiddenFiles', value ?? false),
                  value: state.showHiddenFiles,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 4, 0),
                child: MacosCheckBoxListTile(
                  title: Text('Search in Filename'),
                  onChanged: (value) => context
                      .read<SettingsCubit>()
                      .toggleSearchOption('searchInFilename', value ?? false),
                  value: state.searchInFilename,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 4, 0),
                child: MacosCheckBoxListTile(
                  title: Text('Search in Foldername'),
                  onChanged: (value) => context
                      .read<SettingsCubit>()
                      .toggleSearchOption('searchInFoldername', value ?? false),
                  value: state.searchInFoldername,
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                height: 315,
                width: 220,
                child: DeviceListView(),
              ),
              const SizedBox(height: 16),
            ],
          );
        }
        return Container();
      },
    );
  }
}
