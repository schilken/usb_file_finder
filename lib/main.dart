import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:usb_file_finder/pages/about_window.dart';
import 'package:usb_file_finder/cubit/app_cubit.dart';
import 'package:usb_file_finder/cubit/device_cubit.dart';
import 'package:usb_file_finder/cubit/filter_cubit.dart';
import 'package:usb_file_finder/services/event_bus.dart';
import 'package:usb_file_finder/services/files_repository.dart';
import 'package:usb_file_finder/components/filter_sidebar.dart';
import 'package:usb_file_finder/pages/main_page.dart';
import 'package:usb_file_finder/pages/overview_window.dart';
import 'package:usb_file_finder/preferences/preferences_page.dart';

import 'pages/logger_page.dart';
import 'preferences/preferences_cubit.dart';
import 'preferences/preferences_repository.dart';

/// This method initializes macos_window_utils and styles the window.
Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig();
  await config.apply();
}

Future<void> main(List<String> args) async {
  await _configureMacosWindowUtils();
  print('main: $args');
  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final arguments = args[2].isEmpty
        ? const {}
        : jsonDecode(args[2]) as Map<String, dynamic>;
    if (arguments['args1'] == 'About') {
      runApp(AboutWindow(
        windowController: WindowController.fromWindowId(windowId),
        args: arguments,
      ));
    } else if (arguments['args1'] == 'Overview') {
      runApp(OverviewWindow(
        windowController: WindowController.fromWindowId(windowId),
        args: arguments,
      ));
    }
  } else {
    runApp(const App());
  }
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PreferencesRepository>(
        future: PreferencesRepository().initialize(),
        builder: (context, snapshot) {
          print('builder: ${snapshot.hasData}');
          if (!snapshot.hasData) {
            return Container();
          }
          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider(
                create: (context) => FilesRepository(),
              ),
              RepositoryProvider<PreferencesRepository>.value(
                value: snapshot.data!,
              ),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => FilterCubit(
                    context.read<PreferencesRepository>(),
                  ),
                ),
                BlocProvider(
                  create: (context) =>
                      AppCubit(context.read<FilesRepository>()),
                ),
                BlocProvider(
                  create: (context) => PreferencesCubit(
                    context.read<PreferencesRepository>(),
                    context.read<FilesRepository>(),
                  )..load(),
                ),
                BlocProvider<DeviceCubit>(
                  create: (context) =>
                      DeviceCubit(context.read<FilesRepository>())
                        ..initialize(),
                ),
              ],
              child: MacosApp(
                title: 'usb_file_finder',
                theme: MacosThemeData.light().copyWith(
                  canvasColor: Colors.grey.shade100,
                  dividerColor: Colors.grey.shade300,
                ),
                darkTheme: MacosThemeData.dark(),
                themeMode: ThemeMode.light,
                home: const MainView(),
                debugShowCheckedModeBanner: false,
              ),
            ),
          );
        });
  }
}

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: 'OpenSourceBrowser',
          menus: [
            PlatformMenuItem(
              label: 'About',
              onSelected: () async {
                final window = await DesktopMultiWindow.createWindow(jsonEncode(
                  {
                    'args1': 'About',
                    'args2': 500,
                    'args3': true,
                  },
                ));
                debugPrint('$window');
                window
                  ..setFrame(const Offset(0, 0) & const Size(350, 350))
                  ..center()
                  ..setTitle('About usb_file_finder')
                  ..show();
              },
            ),
            const PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.quit,
            ),
          ],
        ),
      ],
      child: MacosWindow(
//        backgroundColor: Colors.grey.shade100,
        sidebar: Sidebar(
          minWidth: 240,
          // decoration: BoxDecoration(
          //   color: Colors.grey.shade200,
          // ),
          top: const FilterSidebar(),
          builder: (context, scrollController) => Container(
 //           color: Colors.grey.shade200,
            child: SidebarItems(
              currentIndex: _pageIndex,
              scrollController: scrollController,
              itemSize: SidebarItemSize.large,
              onChanged: (index) {
                setState(() => _pageIndex = index);
              },
              items: const [
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.search),
                  label: Text('Search Result'),
                ),
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.graph_square),
                  label: Text('Preferences'),
                ),
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.graph_square),
                  label: Text('Logger'),
                ),
              ],
            ),
          ),
          bottom: Container(
//            color: Colors.grey.shade200,
            child: const MacosListTile(
              leading: MacosIcon(CupertinoIcons.profile_circled),
              title: Text('Alfred Schilken'),
              subtitle: Text('alfred@schilken.de'),
            ),
          ),
        ),
        child: IndexedStack(
          index: _pageIndex,
          children: [
            const MainPage(),
            const PreferencesPage(),
            LoggerPage(eventBus.streamController.stream),
          ],
        ),
      ),
    );
  }
}
