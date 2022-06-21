// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

class ToolbarSearchfield extends ToolbarItem {
  const ToolbarSearchfield({
    Key? key,
    this.placeholder,
  }) : super(key: key);
  final String? placeholder;

  @override
  Widget build(BuildContext context, ToolbarItemDisplayMode displayMode) {
        return SizedBox(width: 150,
          child: MacosSearchField(
                              placeholder: placeholder,
                              maxLines: 1,
                              onTap: () {},
                              onChanged: (value) {
                                print('onChanged: $value');
                              },
                            ),
        );
  }
}
