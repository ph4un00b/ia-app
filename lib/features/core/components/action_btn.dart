import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.text,
    required this.scale,
    required this.handleAction,
    this.color,
  });

  final Icon icon;
  final String text;
  final double scale;
  final Color? color;
  final void Function() handleAction;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icon,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 10 * scale,
          vertical: 10 * scale,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        iconColor: color == null ? null : Colors.lightGreen,
      ),
      onPressed: () {
        handleAction();
      },
      label: Text(
        text,
        style: TextStyle(color: color == null ? null : Colors.lightGreen),
        textScaler: TextScaler.linear(1.4 * scale),
      ),
    );
  }
}
