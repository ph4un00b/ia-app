import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OptOthersScreen extends StatelessWidget {
  const OptOthersScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Otras Opcioness',
            style: GoogleFonts.satisfy(
              textStyle: Theme.of(context).textTheme.displayLarge,
              fontSize: 28,
              fontWeight: FontWeight.w200,
              fontStyle: FontStyle.normal,
            )),
      ),
    );
  }
}
