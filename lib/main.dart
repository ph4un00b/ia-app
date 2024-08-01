import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/root.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: Env.dbUrl,
    anonKey: Env.dbKey,
  );
  runApp(const MyApp());
}
