import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LolaAvatar extends StatelessWidget {
  const LolaAvatar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      // Colors.transparent,
      backgroundImage: Image.asset("assets/common/avatar-lola-1.jpg").image,
      // backgroundImage: NetworkImage(
      //     "<https://randomuser.me/api/portraits/women/84.jpg>"),
      maxRadius: 20,
    );
  }
}

class LolaStatus extends StatelessWidget {
  const LolaStatus({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Lola",
          style: GoogleFonts.satisfy(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: 22,
            fontWeight: FontWeight.w200,
            fontStyle: FontStyle.italic,
          ),
        ),
        Text(
          "Online",
          style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        )
      ],
    );
  }
}
