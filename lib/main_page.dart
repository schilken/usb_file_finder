import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:usb_file_finder/providers/app_notifier.dart';
import 'package:usb_file_finder/providers/app_state_models.dart';
import 'package:usb_file_finder/detail_tile.dart';
import 'package:usb_file_finder/get_custom_toolbar.dart';
import 'package:usb_file_finder/highlighted_text.dart';
import 'package:usb_file_finder/textfield_dialog.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  Future<void> _promptString(BuildContext context, WidgetRef ref) async {
    final exclusionWord = await textFieldDialog(
      context,
      title: const Text('Enter an exclusion word'),
      description: const Text(
          'Only lines NOT containing the entered word\nwill remain in the list.'),
      initialValue: '',
      textOK: const Text('OK'),
      textCancel: const Text('Abbrechen'),
      validator: (String? value) {
        if (value == null || value.isEmpty || value.length < 3) {
          return 'Mindestens 3 Buchstaben oder Ziffern';
        }
        return null;
      },
      barrierDismissible: true,
      textCapitalization: TextCapitalization.words,
      textAlign: TextAlign.center,
    );
    if (exclusionWord != null) {
      await ref.read(appProvider.notifier).addExclusionWord(exclusionWord);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);
    return MacosScaffold(
      toolBar: getCustomToolBar(context, ref),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            if (appState is DetailsLoaded) {
              return Column(
                children: [
                  Container(
                    color: Colors.blueGrey[100],
                    padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        PushButton(
                          controlSize: ControlSize.large,
                          color: Colors.white,
                          child: const Text('Exclude'),
                          onPressed: () => _promptString(context, ref),
                        ),
                        const SizedBox(width: 8),
                        Text(appState.currentSearchParameters),
                        if (appState.currentSearchParameters.contains(':'))
                          MacosIconButton(
                            backgroundColor: Colors.transparent,
                            icon: const MacosIcon(CupertinoIcons.clear_circled),
                            shape: BoxShape.circle,
                            onPressed: () =>
                                ref.read(appProvider.notifier).clearExcludes(),
                          ),
                        const Spacer(),
                        if (appState.isScanRunning)
                          TextButton(
                            onPressed: ref
                                .read(appProvider.notifier)
                                .addToIgnoreFolderList,
                            child: const Text('Add Folder to Ignore List'),
                          ),
                        if (appState.isScanRunning)
                          TextButton(
                            onPressed:
                                ref.read(appProvider.notifier).cancelScan,
                            child: const Text('Cancel Scan'),
                          ),
                        Text(
                            'found ${appState.primaryHitCount}(${appState.secondaryHitCount}) of ${appState.fileCount} Files'),
                      ],
                    ),
                  ),
                  if (appState.message != null)
                    Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.red[100],
                        child: Text(appState.message!)),
                  Expanded(
                    child: ListView.separated(
                      controller: ScrollController(),
                      itemCount: appState.details.length,
                      itemBuilder: (context, index) {
                        final highlights = [
                          appState.primaryWord ?? '@',
                          appState.secondaryWord ?? '@',
                        ];
                        final detail = appState.details[index];
                        if (appState.displayLineCount == 1) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: Row(children: [
                              HighlightedText(
                                text: detail.filePath ?? 'no preview',
                                highlights: highlights,
                              ),
                              const SizedBox(width: 12),
                              const Spacer(),
                              NameWithOpenInEditor(
                                name: detail.folderPath ?? 'no name',
                                path: detail.filePathName,
                              ),
                            ]),
                          );
                        }
                        return DetailTile(
                          detail: detail,
                          highlights: highlights,
                          displayLinesCount: appState.displayLineCount ?? 1,
                          fileType: appState.fileType,
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider(thickness: 2);
                      },
                    ),
                  ),
                ],
              );
            } else if (appState is DetailsLoading) {
              return const CupertinoActivityIndicator();
            }
            return const Center(child: Text('No file selected'));
          },
        ),
      ],
    );
  }
}
