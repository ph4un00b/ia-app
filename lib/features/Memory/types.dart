import 'package:lola_ai_app/features/Agents/types.dart';

class MemoryMessage {
  final QueryKind intent;
  final String role;
  final String content;
  final String? context;
  final DateTime timestamp;

  MemoryMessage({
    required this.timestamp,
    required this.intent,
    required this.role,
    required this.content,
    required this.context,
  });

  @override
  String toString() {
    const letters = 16;
    final shortContent = content.length > letters
        ? '${content.substring(0, letters)}...'
        : content;
    return 'MemoryMessage{datetime: $timestamp, intent: ${intent.name}, role: $role, content: $shortContent, context: $context}';
  }
}
