import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class SettingsWindow extends StatelessWidget {
  const SettingsWindow({
    super.key,
    required this.windowController,
    required this.args,
  });

  final WindowController windowController;
  final Map? args;

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'open_source_browser',
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.system,
      home: MacosWindow(
        child: MacosScaffold(
          children: [
            ContentArea(
              builder: (context, scrollController) {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Preferences',
                        style: MacosTheme.of(context).typography.largeTitle,
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Choose default folders',
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
