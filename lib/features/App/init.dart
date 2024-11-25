import 'package:lola_ai_app/features/User/types.dart';
import 'package:lola_ai_app/features/User/user_settings.dart';

enum AppInitDecision {
  createUserMetadata,
  updateUserStatus,
  none;

  static AppInitDecision from({
    required UserState userState,
    required UserMetadata? userMetadata,
  }) {
    if (userMetadata == null) {
      return AppInitDecision.createUserMetadata;
    } else {
      return switch (userState) {
        UserState.idle => AppInitDecision.updateUserStatus,
        UserState.auth => AppInitDecision.none,
        UserState.onboarding => AppInitDecision.none,
        UserState.active => AppInitDecision.none,
      };
    }
  }
}
