import 'package:flutter/material.dart';
import 'package:lola_ai_app/screens/auth/auth_screen.dart';
import 'package:lola_ai_app/screens/voz/chat_screen.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

var ACTIVE_SESSION = Supabase.instance.client.auth.currentSession;

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // : const VozScreen()),
    return Center(child: ACTIVE_SESSION == null ? const AuthScreen() : const ChatScreen());
  }
}
