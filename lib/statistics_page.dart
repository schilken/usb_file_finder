import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:open_source_browser/cubit/app_cubit.dart';
import 'package:open_source_browser/cubit/settings_cubit.dart';
import 'package:open_source_browser/detail_tile.dart';
import 'package:open_source_browser/highlighted_text.dart';
import 'package:open_source_browser/main_page.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppCubit>(
      create: (context) => AppCubit(context.read<SettingsCubit>()),
      child: Builder(builder: (context) {
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
                          Expanded(
                            child: Center(child: Text('statistics')),
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
            // ResizablePane(
            //     minWidth: 300,
            //     startWidth: 300,
            //     windowBreakpoint: 500,
            //     resizableSide: ResizableSide.left,
            //     builder: (_, __) {
            //       return const Center(child: Text('Details'));
            //     })
          ],
        );
      }),
    );
  }
}
