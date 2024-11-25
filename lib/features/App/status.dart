import 'dart:async';

import 'package:flutter/services.dart';
import 'package:lola_ai_app/config/env.dart';
import 'package:lola_ai_app/features/Lola/types.dart';
import 'package:lola_ai_app/features/Reminders/types.dart';
import 'package:lola_ai_app/features/User/types.dart';
import 'package:lola_ai_app/features/core/types.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum Flavor { dev, stg, prod }

class AppStatus {
  bool _initialized = false;
  Mixpanel? mixpanel;
  SupabaseClient? db;

  var lolaStatus = LolaState.idle;
  var currentUserStatus = UserState.idle;
  var reminderStatus = ReminderState.idle;
  var currentReminder = ReminderData();
  var currentReminderChat = <ChatCompletionMessage>[];

  AppStatus._();
  static final AppStatus _instance = AppStatus._();
  static AppStatus get instance => _instance;

  static Future<void> initialize() async {
    assert(
      !_instance._initialized,
      'This instance is already initialized',
    );

    await _instance._initSupabase();
    await _instance._initMixpanel();
    _instance._initialized = true;
  }

  Future<void> _initSupabase() async {
    final supabase = await Supabase.initialize(
      url: Env.dbUrl,
      anonKey: Env.dbKey,
    );

    db = supabase.client;
  }

  String get userId => db!.auth.currentUser!.id;

  User? get user => db?.auth.currentUser;

  Future<void> activateUser() async {
    if (_instance.currentUserStatus == UserState.active) return;

    _instance.currentUserStatus = UserState.active;
    await Supabase.instance.client
        .from('person_metadata')
        .update({'app_status': UserState.active.name}).eq('user_id', userId);

    unawaited(AppEvent.userActivated.track(params: {'user': _instance.userId}));
  }

  Future<void> _initMixpanel() async {
    mixpanel = await Mixpanel.init(
      Env.mixpanelToken,
      trackAutomaticEvents: true,
    )
      ..setLoggingEnabled(false);
  }

  static bool isOnboarding() => _instance.currentUserStatus == UserState.onboarding;

  static bool isActive() => _instance.currentUserStatus == UserState.active;

  static bool isCreatingReminder() =>
      _instance.lolaStatus == LolaState.creatingReminder &&
      _instance.reminderStatus != ReminderState.filled;

  static Flavor flavor() {
    return switch (appFlavor) {
      'prod' => Flavor.prod,
      'stg' => Flavor.stg,
      'dev' => Flavor.dev,
      null => Flavor.dev, // * if not specified, default to dev
      _ => throw UnsupportedError('Invalid flavor: $appFlavor'),
    };
  }
}
