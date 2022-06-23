import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:open_source_browser/cubit/app_cubit.dart';
import 'package:open_source_browser/cubit/settings_cubit.dart';
import 'package:open_source_browser/highlighted_text.dart';
import 'package:open_source_browser/toolbar_searchfield.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppCubit>(
          create: (context) => AppCubit(),
      child: Builder(builder: (context) {
        return MacosScaffold(
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
                    title: const Text("Scan Examples Folder for Dart Files"),
                    onTap: () async {
                      String selectedDirectory =
                          context.read<SettingsCubit>().examplesFolder;
                      await context.read<AppCubit>().scanFolder(
                          folderPath: selectedDirectory, type: 'dart');
                    },
                  ),
                  MacosPulldownMenuItem(
                    title: const Text("Scan Packages Folder for Dart Files"),
                    onTap: () async {
                      String selectedDirectory =
                          context.read<SettingsCubit>().packagesFolder;
                      await context.read<AppCubit>().scanFolder(
                          folderPath: selectedDirectory, type: 'dart');
                    },
                  ),
                  MacosPulldownMenuItem(
                    title:
                        const Text("Scan Flutter Source Folder for Dart Files"),
                    onTap: () async {
                      String selectedDirectory =
                          context.read<SettingsCubit>().flutterSourceFolder;
                      await context.read<AppCubit>().scanFolder(
                          folderPath: selectedDirectory, type: 'dart');
                    },
                  ),
                  const MacosPulldownMenuDivider(),
                  MacosPulldownMenuItem(
                    title: const Text("Scan Packages Folder for YAML Files"),
                    onTap: () async {
                      String selectedDirectory =
                          context.read<SettingsCubit>().packagesFolder;
                      await context.read<AppCubit>().scanFolder(
                          folderPath: selectedDirectory, type: 'pubspec.yaml');
                      context.read<AppCubit>().setPrimarySearchWord('name:');
                      context.read<AppCubit>().search();
                    },
                  ),

                  MacosPulldownMenuItem(
                    title: const Text("Scan Folder for YAML Files"),
                    onTap: () async {
                      String? selectedDirectory =
                          await FilePicker.platform.getDirectoryPath();
                      if (selectedDirectory != null) {
                        await context
                            .read<AppCubit>()
                            .scanFolder(
                            folderPath: selectedDirectory,
                            type: 'pubspec.yaml');
                        context.read<AppCubit>().setPrimarySearchWord('name:');
                        context.read<AppCubit>().search();
                      }
                    },
                  ),
                  const MacosPulldownMenuDivider(),
                  MacosPulldownMenuItem(
                    title: const Text("Scan Folder for Dart Files"),
                    onTap: () async {
                      String? selectedDirectory =
                          await FilePicker.platform.getDirectoryPath();
                      if (selectedDirectory != null) {
                        context
                            .read<AppCubit>()
                            .scanFolder(
                            folderPath: selectedDirectory, type: 'dart');
                      }
                    },
                  ),
                  MacosPulldownMenuItem(
                    title: const Text("Scan Folder for SVG Files"),
                    onTap: () async {
                      String? selectedDirectory =
                          await FilePicker.platform.getDirectoryPath();
                      if (selectedDirectory != null) {
                        context
                            .read<AppCubit>()
                            .scanFolder(
                            folderPath: selectedDirectory, type: 'svg');
                      }
                    },
                  ),
                  MacosPulldownMenuItem(
                    title: const Text("Open File List"),
                    onTap: () {
                      context.read<AppCubit>().loadFileList();
                    },
                  ),
                  MacosPulldownMenuItem(
                    title: const Text("Save File List"),
                    onTap: () {
                      context.read<AppCubit>().saveFileList();
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
          ),
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
                                if (state.fileType == null)
                                  const Text('Paths from File: ')
                                else
                                  Text('${state.fileType} Files in Folder: '),
                                Text(state.currentPathname),
                                const Spacer(),
                                Text(
                                    '${state.fileCount}|${state.primaryHitCount}|${state.secondaryHitCount}'),
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
                                final detail = state.details[index];
                                return MacosListTile(
                                  title: HighlightedText(
                                      text: detail.previewText ?? 'no preview',
                                      highlights: [
                                        state.primaryWord ?? '@',
                                        state.secondaryWord ?? '@',
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Text(
                                        detail.projectName ?? 'no project',
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        detail.title ?? 'no title',
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (detail.imageUrl != null)
                                        FutureBuilder<String?>(
                                            future:
                                                _loadSvgFile(detail.imageUrl!),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return SvgPicture.string(
                                                    height: 100,
                                                    width: 100,
                                                    snapshot.data ?? '');
                                              }
                                              return CircularProgressIndicator();
                                            })
                                    ],
                                  ),
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
                    return Center(child: const Text('No file selected'));
                  },
                  );
              },
            ),
            ResizablePane(
                minWidth: 300,
                startWidth: 300,
                windowBreakpoint: 500,
                resizableSide: ResizableSide.left,
                builder: (_, __) {
                  return Center(child: Text('Details'));
                })
          ],
        );
      }
          ),
    );
  }
  
  Future<String?> _loadSvgFile(String imageUrl) async {
    final svgAsString = await File(imageUrl).readAsString();
    return svgAsString;
  }
}
