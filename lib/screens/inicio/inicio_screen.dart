import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension StringExt on String {
  String capitalized() => StringUtils.capitalize(this);
  String allCapitalized() => StringUtils.capitalize(this, allWords: true);
}

class InicioScreen extends StatelessWidget {
  const InicioScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var actionBtnText = "presiona para continuar".allCapitalized();
    var mainTitle = "lola app".allCapitalized();
    var scale = 1.0;
    return Scaffold(
        appBar: null,
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AppLogo(text: mainTitle, scale: scale),
          CallToAction(text: actionBtnText, scale: scale)
        ])));
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    required this.text,
    required this.scale,
  });

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: GoogleFonts.satisfy(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: 48 * scale,
            fontWeight: FontWeight.w200,
            fontStyle: FontStyle.italic,
          ),
        ),
        // Text(
        //   text,
        //   style: const TextStyle(fontFamily: 'RobotoMono'),
        //   textScaler: TextScaler.linear(3.5 * scale),
        // ),
        Icon(
          Icons.mic,
          size: 70.0 * scale,
        ),
      ],
    );
  }
}

class CallToAction extends StatelessWidget {
  const CallToAction({
    super.key,
    required this.scale,
    required this.text,
  });

  final double scale;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 38.0 * scale),
      child: ElevatedButton.icon(
          // icon: Icon(Icons.mic),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
                horizontal: 24 * scale, vertical: 22 * scale),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          onPressed: () {
            debugPrint("go");
            Navigator.pushNamed(context, '/voz');
          },
          label: Text(
            text,
            textScaler: TextScaler.linear(1.8 * scale),
          )),
    );
  }
}
