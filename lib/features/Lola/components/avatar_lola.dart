import 'package:flutter/material.dart';

class AvatarLola extends StatelessWidget {
  const AvatarLola({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest,
      // Colors.transparent,
      backgroundImage:
          Image.asset("assets/common/avatar-lola-1.jpg")
              .image,
      // backgroundImage: NetworkImage(
      //     "<https://randomuser.me/api/portraits/women/84.jpg>"),
      maxRadius: 20,
    );
  }
}
