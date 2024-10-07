import 'reminder_agent.dart';
import 'text_agent.dart';
import 'classification_agent.dart';
import 'llm.dart';

enum QueryKind {
  text,
  // TODO: add greeting agent
  greeting,
  reminder,
  none,
}

sealed class LLMResponse {
  String get payload => '';
  QueryKind get intent => QueryKind.none;
}

final class TextResponse implements LLMResponse {
  @override
  final String payload;
  @override
  final QueryKind intent = QueryKind.text;
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
  final QueryKind intent = QueryKind.reminder;
  const ReminderResponse({this.payload = ''});

  @override
  String toString() {
    return 'ReminderResponse';
  }
}

final class NoneResponse implements LLMResponse {
  @override
  final String payload;
  @override
  final QueryKind intent = QueryKind.none;
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

  Future<ResponseType> query(String input) async {
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
      Agent.reminder => ReminderAgent.query(input, llm: _llm),
      Agent.text => TextAgent.query(input, llm: _llm),
    };
  }
}
