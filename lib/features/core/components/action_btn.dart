import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.text,
    required this.scale,
    this.onPressed,
    this.color,
  });

  final Icon icon;
  final String text;
  final double scale;
  final Color? color;
  final void Function()? onPressed;

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
          iconColor: color),
      onPressed: () => onPressed?.call(),
      label: Text(
        text,
        style: TextStyle(color: color),
        textScaler: TextScaler.linear(1.4 * scale),
      ),
    );
  }
}

class ActionButtonAlt extends StatelessWidget {
  const ActionButtonAlt({
    super.key,
    required this.icon,
    required this.text,
    required this.scale,
    this.onPressed,
    this.color,
  });

  final Icon icon;
  final String text;
  final double scale;
  final Color? color;
  final void Function()? onPressed;

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
          iconColor: color,
          backgroundColor: Colors.white10),
      onPressed: () => onPressed?.call(),
      label: Text(
        text,
        style: TextStyle(color: color),
        textScaler: TextScaler.linear(1.4 * scale),
      ),
    );
  }
}
