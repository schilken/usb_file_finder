import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:usb_file_finder/cubit/app_cubit.dart';
import 'package:usb_file_finder/toolbar_searchfield.dart';
import 'package:usb_file_finder/toolbar_widget_toggle.dart';

ToolBar getCustomToolBar(BuildContext context) {
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
                context
                    .read<AppCubit>()
                    .scanFolder(folderPath: selectedDirectory);
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
            context.read<AppCubit>().setPrimarySearchWord(word),
        onSubmitted: (word) {
          context.read<AppCubit>().setPrimarySearchWord(word);
          context.read<AppCubit>().search();
        },
      ),
      ToolbarSearchfield(
        placeholder: 'Secondary word',
        onChanged: (word) =>
            context.read<AppCubit>().setSecondarySearchWord(word),
        onSubmitted: (word) {
          context.read<AppCubit>().setSecondarySearchWord(word);
          context.read<AppCubit>().search();
        },
      ),
      ToolbarWidgetToggle(
        onChanged: (value) {
          print('onChanged: $value');
        },
        child: const Text('Aa'),
      ),
      ToolBarIconButton(
        label: "Search",
        icon: const MacosIcon(
          CupertinoIcons.search,
        ),
        onPressed: () => context.read<AppCubit>().search(),
        showLabel: false,
      ),
      const ToolBarDivider(),
      ToolBarIconButton(
        label: "Share",
        icon: const MacosIcon(
          CupertinoIcons.share,
        ),
        onPressed: () => debugPrint("pressed"),
        showLabel: false,
      ),
    ],
  );
}
