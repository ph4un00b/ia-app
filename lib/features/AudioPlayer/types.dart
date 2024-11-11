import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lola_ai_app/features/core/types.dart';

import '../core/components/action_btn.dart';

mixin AudioPlayerHandlers {
  Future<void> stopAudio();
  Future<void> playAudio();
}

typedef AudioCallback = Future<void> Function();

sealed class AudioState {
  Widget buildButton({
    required String text,
    required double scale,
    required IconData icon,
    AudioCallback? onPressed,
    Color? color,
  }) =>
      ActionButton(
        icon: Icon(icon),
        text: text,
        scale: scale,
        color: color,
        onPressed: onPressed,
      );
}

extension PlayButtonConfig on AudioState {
  Widget buildPlayButton({
    required double scale,
    AudioCallback? onPressed,
    Color? color,
  }) =>
      buildButton(
        scale: scale,
        onPressed: onPressed,
        text: 'Repetir',
        icon: Icons.play_arrow_rounded,
        color: color,
      );
}

final class NoAudioPath extends AudioState {
  Widget build({required double scale}) =>
      buildPlayButton(scale: scale, color: Colors.grey);
}

final class PlayingAudio extends AudioState {
  Widget build({required double scale, required AudioCallback onStop}) =>
      buildButton(
          scale: scale, onPressed: onStop, text: 'Parar', icon: Icons.stop);
}

final class PlayingAudioErr extends AudioState {
  Widget build({required double scale, required AudioCallback onRetry}) =>
      buildPlayButton(scale: scale, onPressed: onRetry, color: Colors.green);
}

final class PlayingAudioOk extends AudioState {
  Widget build({
    required String from,
    required double scale,
    required AudioCallback onReplay,
  }) =>
      buildPlayButton(
        scale: scale,
        color: Colors.green,
        onPressed: () async {
          unawaited(AppEvent.lolaMessageReplayed.track(params: {'from': from}));
          await onReplay();
        },
      );
}

final class Stopped extends AudioState {
  Widget build({required double scale, required AudioCallback onPlay}) =>
      buildPlayButton(scale: scale, onPressed: onPlay);
}

final class StoppedErr extends AudioState {
  Widget build({required double scale, required AudioCallback onPlay}) =>
      buildPlayButton(scale: scale, onPressed: onPlay);
}
