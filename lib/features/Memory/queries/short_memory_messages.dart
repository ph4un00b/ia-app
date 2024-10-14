import 'package:lola_ai_app/features/Agents/types.dart';
import 'package:lola_ai_app/features/Memory/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShortMemoryMessages {
  static Future<String> generate() async {
    final result = await _query();
    String messages = _prepare(result);
    return messages;
  }

  static Future<String> userQuestions() async {
    List<Map<String, dynamic>> result = await Supabase.instance.client
        .from('conversation')
        .select()
        .not('intent', 'eq', IntentKind.greeting.name)
        .not('system', 'eq', 'lola')
        .order('created_at', ascending: false)
        .limit(36);

    var messages = _messagesFrom(result);
    return _prepare(messages);
  }

  static Future<List<MemoryEntry>> _query() async {
    List<Map<String, dynamic>> result = await Supabase.instance.client
        .from('conversation')
        .select()
        .not('intent', 'eq', IntentKind.greeting.name)
        .order('created_at', ascending: false)
        // TODO: constant
        .limit(36);

    var messages = _messagesFrom(result);
    return messages;
  }

  static List<MemoryEntry> _messagesFrom(
    List<Map<String, dynamic>> data,
  ) {
    return List<MemoryEntry>.generate(data.length, (i) {
      final row = data[i];
      final IntentKind intent =
          IntentKind.values.firstWhere((e) => e.name == row['intent']);
      final String content = row['content'];
      final String from = row['system'];
      // TODO(app.messages): manage timezones.
      final DateTime createdAt = DateTime.parse(row['created_at']);

      return MemoryEntry(
        timestamp: createdAt,
        intent: intent,
        role: from,
        content: content,
        context: null,
      );
    });
  }

  static String _prepare(List<MemoryEntry> list) {
    List<String> msgs = [];
    // XXX: list can be reversed. depending on the query order.
    for (var msg in list.reversed) {
      if (msg.role == 'user') {
        msgs.add('<USER>\n${msg.content}\n</USER>\n');
      } else {
        msgs.add('<LOLA>\n${msg.content}\n</LOLA>\n');
      }
    }
    return msgs.join("");
  }
}
