import 'package:lola_ai_app/features/Agents/types.dart';

class MemoryEntry {
  final IntentKind intent;
  final String role;
  final String content;
  final String? context;
  final DateTime timestamp;

  MemoryEntry({
    required this.timestamp,
    required this.intent,
    required this.role,
    required this.content,
    required this.context,
  });

  @override
  String toString() {
    const maxPreviewLength = 16;
    final contentPreview = content.length > maxPreviewLength
        ? '${content.substring(0, maxPreviewLength)}...'
        : content;
    return 'MemoryEntry{datetime: $timestamp, intent: ${intent.name}, role: $role, content: $contentPreview, context: $context}';
  }
}
