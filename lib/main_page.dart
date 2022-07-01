import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:usb_file_finder/cubit/app_cubit.dart';
import 'package:usb_file_finder/detail_tile.dart';
import 'package:usb_file_finder/get_custom_toolbar.dart';
import 'package:usb_file_finder/highlighted_text.dart';
import 'package:usb_file_finder/textfield_dialog.dart';
class MainPage extends StatelessWidget {
  const MainPage({super.key});


promptString(BuildContext context) async {
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
      await context.read<AppCubit>().addExclusionWord(exclusionWord);
    }
  }

  macosPromptString(BuildContext context) {
    showMacosAlertDialog(
      context: context,
      builder: (context) => MacosAlertDialog(
        appIcon: const FlutterLogo(
          size: 56,
        ),
        title: const Text(
          'Alert Dialog with Secondary Action',
        ),
        message: const Text(
          'This is an alert dialog with primary action and secondary action laid out horizontally',
          textAlign: TextAlign.center,
        ),
        //horizontalActions: false,
        primaryButton: PushButton(
          buttonSize: ButtonSize.large,
          onPressed: Navigator.of(context).pop,
          child: const Text('Primary'),
        ),
        secondaryButton: PushButton(
          buttonSize: ButtonSize.large,
          isSecondary: true,
          onPressed: Navigator.of(context).pop,
          child: const Text('Secondary'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
        return MacosScaffold(
          toolBar: getCustomToolBar(context),
          children: [
            ContentArea(
              builder: (context, scrollController) {
                return BlocBuilder<AppCubit, AppState>(
                  builder: (context, state) {
                    if (state is DetailsLoaded) {
                      return Column(
                        children: [
                          Container(
                            color: Colors.blueGrey[100],
                            padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              PushButton(
                                buttonSize: ButtonSize.large,
                                isSecondary: true,
                                color: Colors.white,
                                child: const Text('Exclude'),
                                onPressed: () => promptString(context),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(state.currentSearchParameters),
                              if (state.currentSearchParameters.contains(':'))
                                MacosIconButton(
                                  backgroundColor: Colors.transparent,
                                  icon: MacosIcon(
                                    CupertinoIcons.clear_circled,
                                  ),
                                  shape: BoxShape.circle,
                                  onPressed: () =>
                                      context.read<AppCubit>().clearExcludes(),
                                ),
                                const Spacer(),
                              if (state.isScanRunning)
                                TextButton(
                                    onPressed:
                                        context.read<AppCubit>().cancelScan,
                                    child: const Text('Cancel Scan')),
                                Text(
                                  'found ${state.primaryHitCount}(${state.secondaryHitCount}) of ${state.fileCount} Files'),
                              ],
                            ),
                          ),
                          if (state.message != null)
                            Container(
                                padding: const EdgeInsets.all(20),
                                color: Colors.red[100],
                                child: Text(state.message!)),
                          Expanded(
                            child: ListView.separated(
                              controller: ScrollController(),
                              itemCount: state.details.length,
                              itemBuilder: (context, index) {
                                final highlights = [
                                  state.primaryWord ?? '@',
                                  state.secondaryWord ?? '@',
                                ];

                                final detail = state.details[index];
                                if (state.displayLineCount == 1) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8),
                                    child: Row(children: [
                                      HighlightedText(
                                        text:
                                            detail.filePath ?? 'no preview',
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
                                  displayLinesCount:
                                      state.displayLineCount ?? 1,
                                  fileType: state.fileType,
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const Divider(
                                  thickness: 2,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    } else if (state is DetailsLoading) {
                      return const CupertinoActivityIndicator();
                    }
                    return const Center(child: Text('No file selected'));
                  },
                );
              },
          ),
          ],
        );
    });
  }
}
