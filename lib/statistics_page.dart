import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:open_source_browser/cubit/app_cubit.dart';
import 'package:open_source_browser/cubit/statistics_cubit.dart';
import 'package:open_source_browser/files_repository.dart';
import 'package:open_source_browser/main_page.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StatisticsCubit>(
      create: (context) => StatisticsCubit(context.read<FilesRepository>()),
      child: Builder(builder: (context) {
        return MacosScaffold(
          toolBar: getCustomToolBar(context),
          children: [
            ContentArea(
              builder: (context, scrollController) {
                return BlocBuilder<StatisticsCubit, StatisticsState>(
                  builder: (context, state) {
                    if (state is DetailsLoaded) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              color: Colors.blueGrey[100],
                              padding:
                                  const EdgeInsets.fromLTRB(12, 20, 20, 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                    const Text('Paths from File: ')
                                ],
                              ),
                            ),
                            Expanded(
                              child: Center(child: Text('statistics')),
                            ),
                          ],
                        ),
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
      }),
    );
  }
}
