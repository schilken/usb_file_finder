import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:usb_file_finder/cubit/preferences_cubit.dart';
import 'package:usb_file_finder/get_custom_toolbar.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('PreferencesPage.build');
    return Builder(builder: (context) {
      return MacosScaffold(
        toolBar: getCustomToolBar(context),
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return BlocBuilder<PreferencesCubit, PreferencesState>(
                builder: (context, state) {
//                    print('builder: $state');
                  if (state is PreferencesLoaded) {
                    return Column(
                      children: [
                        Container(
                          color: Colors.blueGrey[100],
                          padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text('Paths from File: '),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else if (state is PreferencesLoading) {
                    return const CupertinoActivityIndicator();
                  }
                  return Center(
                      child:
                          TextButton(onPressed: () {}, child: Text('refresh')));
                },
              );
            },
          ),
        ],
      );
    });
  }
}
