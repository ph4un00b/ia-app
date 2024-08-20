import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Conversation {
  static Future<void> save({
    required String user,
    required String lola,
    required String audioPath,
  }) async {
    debugPrint('save conversation: lola: $lola');
    debugPrint('save conversation: path: $audioPath');
    debugPrint('save conversation: ${DateTime.now().toIso8601String()}');
    // TODO: duplication error on bad connection:
    // PostgrestException(message: duplicate key value violates unique constraint
    await Supabase.instance.client.from('conversation').insert([
      {
        'title': '',
        'content': user,
        'system': 'user',
        // TODO: use user id from auth
        'user_id': 1,
        'created_at': DateTime.now().toIso8601String()
      },
      {
        'title': '',
        'content': lola,
        'system': 'lola',
        // TODO: use user id from auth
        'user_id': 1,
        'created_at':
            DateTime.now().add(const Duration(seconds: 1)).toIso8601String(),
        'path': audioPath,
      },
    ]);
  }
}
