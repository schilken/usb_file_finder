import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:usb_file_finder/cubit/statistics_notifier.dart';
import 'package:usb_file_finder/get_custom_toolbar.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('StatisticsPage.build');
    final state = ref.watch(statisticsProvider);
    return MacosScaffold(
      toolBar: getCustomToolBar(context, ref),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            if (state is StatisticsLoaded) {
              return Column(
                children: [
                  Container(
                    color: Colors.blueGrey[100],
                    padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text('Paths from File: '),
                        Text(state.currentPathname),
                        const Spacer(),
                        Text('${state.fileCount}'),
                      ],
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          ref.read(statisticsProvider.notifier).load(),
                      child: const Text('refresh'),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: ScrollController(),
                      itemCount: state.frequencies.length,
                      itemBuilder: (context, index) {
                        final nameAndCount = state.frequencies[index];
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Row(children: [
                            Text(nameAndCount.name),
                            const SizedBox(width: 12),
                            Text(nameAndCount.count.toString()),
                          ]),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider(thickness: 2);
                      },
                    ),
                  ),
                ],
              );
            } else if (state is StatisticsLoading) {
              return const CupertinoActivityIndicator();
            }
            return Center(
              child: TextButton(
                onPressed: () => ref.read(statisticsProvider.notifier).load(),
                child: const Text('refresh'),
              ),
            );
          },
        ),
      ],
    );
  }
}
