import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Voz',
          style: GoogleFonts.satisfy(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: 28,
            fontWeight: FontWeight.w200,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => _showFormatTypographyBottomSheet(context),
            child: Icon(Icons.text_fields),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: true
                    ? Container(
                        child: Icon(
                          Icons.multitrack_audio,
                          size: 72,
                        ),
                      )
                    : Text("lorem"),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(),
                  ),
                  SizedBox(width: 10),
                  IconButton.filledTonal(
                    onPressed: () {},
                    icon: Icon(Icons.mic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFormatTypographyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      barrierColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {},
                  child: Icon(Icons.text_decrease, size: 16),
                ),
              ),
              SizedBox(width: 3),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {},
                  child: Icon(Icons.text_increase, size: 22),
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: FilledButton.tonal(
                  onPressed: () {},
                  child: Icon(Icons.format_clear, size: 22),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
