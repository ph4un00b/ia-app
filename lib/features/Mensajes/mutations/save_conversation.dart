import 'package:lola_ai_app/features/App/status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Conversation {
  static Future<void> save({
    required String user,
    required String lola,
    required String audioPath,
  }) async {
    // PosgrestException's are handled above
    // PostgrestException(message: duplicate key value violates unique constraint
    await Supabase.instance.client.from('conversation').insert([
      {
        'title': '',
        'content': user,
        'system': 'user',
        'user_id': AppStatus.instance.userId,
        'created_at': DateTime.now().toIso8601String()
      },
      {
        'title': '',
        'content': lola,
        'system': 'lola',
        'user_id': AppStatus.instance.userId,
        'created_at':
            DateTime.now().add(const Duration(seconds: 1)).toIso8601String(),
        'path': audioPath,
      },
    ]);
  }
}
