import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:lola_ai_app/main.dart';

mixin ContentHandler {
  String content();
  void updateContent(String value);
}

mixin QueryContent {
  String content();
}

enum AppEvent {
  summaryFinished,
  summaryFetched,
  remindersFetched,
  remindersFirstTime,
  remindersFinished,
  reminderIdle,
  reminderDraft,
  reminderFilled,
  reminderCreated,
  reminderEdited,
  questionByVoice,
  questionByTyping,
  messagesDisplayed,
  searchMessageUsed,
  lolaMessageDisplayed,
  lolaMessageReplayed,
  userMessageDisplayed;

  Future<void> track({
    Map<String, dynamic> params = const {},
  }) async {
    kReleaseMode
        ? await AppStatus.instance.mixpanel?.track(name, properties: params)
        : log('$this $params', name: 'Event');
  }
}
