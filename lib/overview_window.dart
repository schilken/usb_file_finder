// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:usb_file_finder/files_repository.dart';
import 'package:usb_file_finder/models/storage_info.dart';

class NameValue {
  final String name;
  final int value;
  NameValue(
    this.name,
    this.value,
  );
}

class OverviewWindow extends StatelessWidget {
  const OverviewWindow({
    super.key,
    required this.windowController,
    required this.args,
  });

  final WindowController windowController;
  final Map args;

  @override
  Widget build(BuildContext context) {
    print('OverviewWindow args: $args');
    final storageInfo = StorageInfo.fromJson(args['storageInfo']);
    final nameValueList = <NameValue>[];
    storageInfo.fileCountMap.entries
        .forEach((e) => nameValueList.add(NameValue(e.key, e.value)));
    return MacosApp(
      title: 'usb_file_finder',
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.system,
      home: MacosWindow(
        child: MacosScaffold(
          children: [
            ContentArea(
              minWidth: 600,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Storage Details for ${storageInfo.name}',
                        style: MacosTheme.of(context).typography.largeTitle,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Total number of files: ${storageInfo.totalFileCount}',
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                            itemCount: nameValueList.length,
                            itemBuilder: (context, index) {
                              return NameValueTile(
                                  nameValue: nameValueList[index]);
                            }),
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

class NameValueTile extends StatelessWidget {
  const NameValueTile({
    Key? key,
    required this.nameValue,
  }) : super(key: key);

  final NameValue nameValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nameValue.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Text(
            '${nameValue.value}',
          ),
        ],
      ),
    );
  }
}
