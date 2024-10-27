import 'package:flutter/material.dart';

import '../core/components/action_btn.dart';

mixin AudioPlayerHandlers {
  Future<void> stopAudio();

  Future<void> playAudio();
}

typedef AudioCallback = Future<void> Function();

sealed class AudioState {}

final class NoAudioPath implements AudioState {
  Widget actionDisabled({required double scale}) {
    return ActionButton(
      icon: const Icon(Icons.play_arrow_rounded),
      text: 'Repetir',
      scale: scale,
      color: Colors.grey,
    );
  }
}

final class PlayingAudio implements AudioState {
  Widget stop(
      {required double scale, required AudioCallback onStop}) {
    return ActionButton(
      icon: const Icon(Icons.stop),
      text: 'Parar',
      scale: scale,
      onPressed: () => onStop(),
    );
  }
}

final class PlayingAudioErr implements AudioState {
  Widget replay(
      {required double scale, required AudioCallback onRetry}) {
    return ActionButton(
      icon: const Icon(Icons.play_arrow_rounded),
      text: 'Repetir',
      scale: scale,
      color: Colors.green,
      onPressed: () => onRetry(),
    );
  }
}

final class PlayingAudioOk implements AudioState {
  Widget replay(
      {required double scale, required AudioCallback onReplay}) {
    return ActionButton(
      icon: const Icon(Icons.play_arrow_rounded),
      text: 'Repetir',
      scale: scale,
      color: Colors.green,
      onPressed: () => onReplay(),
    );
  }
}

final class Stopped implements AudioState {
  Widget play(double scale, {required AudioCallback onPlay}) {
    return ActionButton(
      icon: const Icon(Icons.play_arrow_rounded),
      text: 'Repetir',
      scale: scale,
      onPressed: () => onPlay(),
    );
  }
}

final class StoppedErr implements AudioState {
  Widget play(double scale, {required AudioCallback onPlay}) {
    return ActionButton(
      icon: const Icon(Icons.play_arrow_rounded),
      text: 'Repetir',
      scale: scale,
      onPressed: () => onPlay(),
    );
  }
}
