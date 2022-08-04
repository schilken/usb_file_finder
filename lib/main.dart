import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:usb_file_finder/about_window.dart';
import 'package:usb_file_finder/cubit/app_cubit.dart';
import 'package:usb_file_finder/cubit/device_cubit.dart';
import 'package:usb_file_finder/cubit/preferences_cubit.dart';
import 'package:usb_file_finder/cubit/settings_cubit.dart';
import 'package:usb_file_finder/event_bus.dart';
import 'package:usb_file_finder/files_repository.dart';
import 'package:usb_file_finder/filter_sidebar.dart';
import 'package:usb_file_finder/main_page.dart';
import 'package:usb_file_finder/overview_window.dart';
import 'package:usb_file_finder/settings_window.dart';
import 'package:usb_file_finder/preferences_page.dart';
import 'package:usb_file_finder/preferences_page.dart';

import 'logger_page.dart';

void main(List<String> args) {
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
    } else if (arguments['args1'] == 'Preferences') {
      runApp(SettingsWindow(
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
    return FutureBuilder<SettingsCubit>(
        future: SettingsCubit().initialize(),
        builder: (context, snapshot) {
          print('builder: ${snapshot.hasData}');
          if (!snapshot.hasData) {
            return Container();
          }
          return RepositoryProvider(
            create: (context) => FilesRepository(),
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(
                  value: snapshot.data!,
                ),
                BlocProvider(
                  create: (context) => AppCubit(context.read<SettingsCubit>(),
                      context.read<FilesRepository>()),
                ),
                BlocProvider(
                  create: (context) => PreferencesCubit(
                      context.read<SettingsCubit>(),
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
                theme: MacosThemeData.light(),
                darkTheme: MacosThemeData.dark(),
                themeMode: ThemeMode.system,
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
            PlatformMenuItem(
              label: 'Preferences',
              onSelected: () async {
                final window = await DesktopMultiWindow.createWindow(jsonEncode(
                  {
                    'args1': 'Preferences',
                    'args2': 500,
                    'args3': true,
                  },
                ));
                debugPrint('$window');
                window
                  ..setFrame(const Offset(0, 0) & const Size(500, 400))
                  ..center()
                  ..setTitle('The Preferences')
                  ..show();
              },
            ),
            const PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.quit,
            ),
          ],
        ),
      ],
      body: MacosWindow(
        sidebar: Sidebar(
          minWidth: 240,
          top: const FilterSidebar(),
          builder: (context, scrollController) => SidebarItems(
            currentIndex: _pageIndex,
            scrollController: scrollController,
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
          bottom: const MacosListTile(
            leading: MacosIcon(CupertinoIcons.profile_circled),
            title: Text('Alfred Schilken'),
            subtitle: Text('alfred@schilken.de'),
          ),
        ),
        child: IndexedStack(
          index: _pageIndex,
          children: [
            MainPage(),
            PreferencesPage(),
            LoggerPage(eventBus.streamController.stream),
          ],
        ),
      ),
    );
  }
}
