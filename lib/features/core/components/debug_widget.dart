import 'package:flutter/material.dart';

class DebugWidget extends StatelessWidget {
  const DebugWidget({
    super.key,
    required this.children,
  });

  final Widget children;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Card(
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