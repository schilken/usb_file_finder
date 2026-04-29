import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:usb_file_finder/cubit/app_notifier.dart';
import 'package:usb_file_finder/toolbar_searchfield.dart';
import 'package:usb_file_finder/toolbar_widget_toggle.dart';

ToolBar getCustomToolBar(BuildContext context, WidgetRef ref) {
  return ToolBar(
    title: const Text('USB File Finder'),
    titleWidth: 250.0,
    actions: [
      ToolBarIconButton(
        label: 'Toggle Sidebar',
        icon: const MacosIcon(CupertinoIcons.sidebar_left),
        showLabel: false,
        tooltipMessage: 'Toggle Sidebar',
        onPressed: () {
          MacosWindowScope.of(context).toggleSidebar();
        },
      ),
      const ToolBarSpacer(spacerUnits: 3),
      ToolBarPullDownButton(
        label: "Actions",
        icon: CupertinoIcons.ellipsis_circle,
        tooltipMessage: "Perform tasks with the selected items",
        items: [
          MacosPulldownMenuItem(
            title: const Text("Open Folder to scan all Files"),
            onTap: () async {
              String? selectedDirectory = await FilePicker.platform
                  .getDirectoryPath(initialDirectory: '/Volumes');
              if (selectedDirectory != null) {
                ref
                    .read(appProvider.notifier)
                    .scanVolume(volumePath: selectedDirectory);
              }
            },
          ),
        ],
      ),
      const ToolBarSpacer(spacerUnits: 1),
      const ToolBarDivider(),
      const ToolBarSpacer(spacerUnits: 1),
      ToolbarSearchfield(
        placeholder: 'Primary word',
        onChanged: (word) =>
            ref.read(appProvider.notifier).setPrimarySearchWord(word),
        onSubmitted: (word) {
          ref.read(appProvider.notifier).setPrimarySearchWord(word);
          ref.read(appProvider.notifier).search();
        },
      ),
      ToolbarSearchfield(
        placeholder: 'Secondary word',
        onChanged: (word) =>
            ref.read(appProvider.notifier).setSecondarySearchWord(word),
        onSubmitted: (word) {
          ref.read(appProvider.notifier).setSecondarySearchWord(word);
          ref.read(appProvider.notifier).search();
        },
      ),
      ToolbarWidgetToggle(
          onChanged: ref.read(appProvider.notifier).setCaseSentitiv,
          child: const Text('Aa'),
          tooltipMessage: 'Search case sentitiv'),
      ToolBarIconButton(
        label: "Search",
        icon: const MacosIcon(CupertinoIcons.search),
        onPressed: () => ref.read(appProvider.notifier).search(),
        showLabel: false,
        tooltipMessage: 'Start new Search',
      ),
      const ToolBarDivider(),
      ToolBarIconButton(
        label: "Share",
        icon: const MacosIcon(CupertinoIcons.share),
        onPressed: () => debugPrint("pressed"),
        showLabel: false,
      ),
    ],
  );
}
