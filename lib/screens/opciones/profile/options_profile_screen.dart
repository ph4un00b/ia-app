import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OptProfileScreen extends StatelessWidget {
  const OptProfileScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Opciones de Perfil',
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
