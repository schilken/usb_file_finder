// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

typedef BoolCallback = void Function(bool);

class ToolbarWidgetToggle extends ToolbarItem {
  // ignore: prefer_const_constructors_in_immutables
  ToolbarWidgetToggle({
    super.key,
    this.value = false,
    required this.onChanged,
    required this.child,
    this.tooltipMessage,
  });
  final bool value;
  final BoolCallback onChanged;
  final Widget child;
  final String? tooltipMessage;

  @override
  Widget build(BuildContext context, ToolbarItemDisplayMode displayMode) {
    Widget widgetToggleButton = SizedBox(
      width: 110,
      child: WidgetToggleButton(
        value: value,
        onChanged: onChanged,
        child: child,
      ),
    );
    if (tooltipMessage != null) {
      widgetToggleButton = MacosTooltip(
        message: tooltipMessage!,
        child: widgetToggleButton,
      );
    }
    return widgetToggleButton;
  }
}

class WidgetToggleButton extends StatelessWidget {
  const WidgetToggleButton({
    super.key,
    required this.child,
    required this.onChanged,
    required this.value,
  });
  final bool value;
  final BoolCallback onChanged;
  final Widget child;

  void _onPressed() {
    onChanged(!value);
  }

  @override
  Widget build(BuildContext context) {
    return (child is Icon)
        ? MacosIconButton(
            onPressed: _onPressed,
            backgroundColor: value ? Colors.green[100] : Colors.white,
            icon: child,
          )
        : PushButton(
            onPressed: _onPressed,
            controlSize: ControlSize.large,
            color: value ? Colors.green[100] : Colors.white,
            child: child,
          );
  }
}
