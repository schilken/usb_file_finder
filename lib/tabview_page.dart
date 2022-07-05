import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:usb_file_finder/chip_list_editor.dart';
import 'package:usb_file_finder/list_editor.dart';

class TabViewPage extends StatefulWidget {
  const TabViewPage({super.key});

  @override
  State<TabViewPage> createState() => _TabViewPageState();
}

class _TabViewPageState extends State<TabViewPage> {
  final _controller = MacosTabController(
    initialIndex: 0,
    length: 3,
  );

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: const ToolBar(
        title: Text('Preferences'),
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: MacosTabView(
                controller: _controller,
                tabs: [
                  MacosTab(
                    label: 'General',
                    active: _controller.index == 0,
                  ),
                  MacosTab(
                    label: 'Ignore Folders for Scan',
                    active: _controller.index == 1,
                  ),
                  MacosTab(
                    label: 'Exclude Strings from Search',
                    active: _controller.index == 2,
                  ),
                ],
                children: const [
                  Center(
                    child: Text('Tab 1'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: ListEditor(),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: ChipListEditor(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
