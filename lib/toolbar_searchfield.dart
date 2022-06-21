// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

typedef StringCallback = void Function(String);

class ToolbarSearchfield extends ToolbarItem {
  const ToolbarSearchfield({
    Key? key,
    this.placeholder,
    required this.onChanged,
  }) : super(key: key);
  final String? placeholder;
  final StringCallback onChanged;

  @override
  Widget build(BuildContext context, ToolbarItemDisplayMode displayMode) {
    return SizedBox(
      width: 150,
      child: MacosSearchField(
        placeholder: placeholder,
        maxLines: 1,
        onTap: () {},
        onChanged: onChanged,
      ),
    );
  }
}
