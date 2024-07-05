import 'package:flutter/material.dart';

class DebugAltWidget extends StatelessWidget {
  const DebugAltWidget({
    super.key,
    required this.children,
  });

  final Widget children;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Card.filled(
        // color: Colors.amber[900],
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {},
          splashColor: Colors.purple.withAlpha(30),
          child: children,
        ),
      ),
    );
  }
}