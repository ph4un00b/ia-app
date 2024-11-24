import 'package:lola_ai_app/main.dart';

import 'reminder_agent.dart';
import 'text_agent.dart';
import 'classification_agent.dart';
import 'llm.dart';

enum IntentKind {
  text,
  // TODO: add greeting agent?
  greeting,
  reminder,
  createReminder,
  none,
}

sealed class LLMResponse {
  String get payload => '';
  IntentKind get intent => IntentKind.none;
}

final class TextResponse implements LLMResponse {
  @override
  final String payload;
  @override
  final IntentKind intent = IntentKind.text;
  const TextResponse({this.payload = ''});

  @override
  String toString() {
    return 'TextResponse';
  }
}

final class ReminderResponse implements LLMResponse {
  @override
  final String payload;
  @override
  final IntentKind intent = IntentKind.reminder;

  final ReminderState status;

  const ReminderResponse({this.payload = '', this.status = ReminderState.idle});

  @override
  String toString() {
    return 'ReminderResponse';
  }
}

final class NoneResponse implements LLMResponse {
  @override
  final String payload;
  @override
  final IntentKind intent = IntentKind.none;
  const NoneResponse({this.payload = ''});

  @override
  String toString() {
    return 'NoneResponse';
  }
}

// configurations global setup for the agents.
enum StructuredAgent {
  classification(llm: LLM.openaiStructuredOutput);

  const StructuredAgent({required LLM llm}) : _llm = llm;

  final LLM _llm;

  Future<IntentKind> query(String input) async {
    return switch (this) {
      StructuredAgent.classification => ClassifyAgent.query(input, llm: _llm),
    };
  }
}

enum Agent {
  reminder(llm: LLM.openaiAssistant),
  text(llm: LLM.openaiChat);

  const Agent({required LLM llm}) : _llm = llm;

  final LLM _llm;

  Future<LLMResponse> query(String input) async {
    return switch (this) {
      Agent.reminder => ReminderAgent.query(input),
      Agent.text => TextAgent.query(input, llm: _llm),
    };
  }
}
