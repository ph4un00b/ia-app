import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/core/elevenlabs/api.dart';
import 'package:lola_ai_app/secrets.dart' as secrets;

class DebugShowVoices extends StatelessWidget {
  const DebugShowVoices({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Card.outlined(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.green.withAlpha(30),
          onTap: () async {
            debugPrint('>> 11-labs');
            var api = ElevenLabsAPI();
            // try {
            api.init(
                config: const ElevenLabsConfig(apiKey: secrets.ELEVEN_API_KEY));
            var response = await api.listVoices();
            var females = response.voices
                    ?.toList()
                    .where((voice) => voice.labels?.gender == 'female')
                    .where((voice) => voice.fineTuning?.language == 'es') ??
                [];
            // } catch (e) {
            //   debugPrint(e.toString());
            // }
            for (var voice in females) {
              // print(voice.labels?.toJson());
              debugPrint(
                  '>> voice: ${voice.name}, ${voice.voiceId}, ${voice.fineTuning?.language}, ${voice.labels?.accent}');
            }
          },
          child: const Text(
            '11-labss',
            textScaler: TextScaler.linear(1.6),
            maxLines: 4,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}