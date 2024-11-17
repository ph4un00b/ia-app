import 'package:lola_ai_app/features/User/types.dart';
import 'package:lola_ai_app/features/User/user_settings.dart';

enum AppInitDecision {
  createUserMetadata,
  updateUserStatus,
  none;

  static AppInitDecision from({
    required AppUserState userState,
    required UserMetadata? userMetadata,
  }) {
    if (userMetadata == null) {
      return AppInitDecision.createUserMetadata;
    } else {
      return switch (userState) {
        AppUserState.idle => AppInitDecision.updateUserStatus,
        AppUserState.auth => AppInitDecision.none,
        AppUserState.onboarding => AppInitDecision.none,
        AppUserState.active => AppInitDecision.none,
      };
    }
  }
}
