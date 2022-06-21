import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:open_source_browser/cubit/app_cubit.dart';
import 'package:open_source_browser/toolbar_searchfield.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return BlocProvider<AppCubit>(
          create: (context) => AppCubit(),
          child: MacosScaffold(
            toolBar: ToolBar(
              title: const Text('Open Source Browser'),
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
                ToolBarSpacer(spacerUnits: 3),
                ToolBarPullDownButton(
                  label: "Actions",
                  icon: CupertinoIcons.ellipsis_circle,
                  tooltipMessage: "Perform tasks with the selected items",
                  items: [
                    MacosPulldownMenuItem(
                      label: "Open file list",
                      title: const Text("Open File List"),
                      onTap: () {
                        context.read<AppCubit>().loadFileList();
                      },
                    ),
                    const MacosPulldownMenuDivider(),
                    MacosPulldownMenuItem(
                      label: "Remove",
                      enabled: false,
                      title: const Text('Remove'),
                      onTap: () => debugPrint("Deleting..."),
                    ),
                  ],
                ),
                const ToolBarDivider(),
                const ToolbarSearchfield(placeholder: 'Primary word'),
                const ToolbarSearchfield(placeholder: 'Secondary word'),
                ToolBarIconButton(
                  label: "Search",
                  icon: const MacosIcon(
                    CupertinoIcons.search,
                  ),
                  onPressed: () => debugPrint("Search ..."),
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
            ),
            children: [
              ContentArea(
                builder: (context, scrollController) {
                  return const Center(
                    child: Text('Home'),
                  );
                },
              ),
              ResizablePane(
                  minWidth: 300,
                  startWidth: 300,
                  windowBreakpoint: 800,
                  resizableSide: ResizableSide.left,
                  builder: (_, __) {
                    return Center(child: Text('details'));
                  })
            ],
          ),
        );
      },
    );
  }
}
