import 'package:lola_ai_app/features/App/init.dart';
import 'package:lola_ai_app/features/User/types.dart';
import 'package:lola_ai_app/features/User/user_settings.dart';
import 'package:test/test.dart';

extension TestUserMetadata on UserMetadata {
  static UserMetadata create({
    required AppUserState appStatus,
  }) =>
      UserMetadata(
        reminderFileId: 'reminderFileId',
        vectorId: 'vectorId',
        assistantId: 'assistantId',
        appStatus: appStatus,
      );
}

void main() {
  group('AppInitDecision.from', () {
    test('creates user metadata when metadata is null', () {
      expect(
        AppInitDecision.from(
          userState: AppUserState.idle,
          userMetadata: null,
        ),
        AppInitDecision.createUserMetadata,
      );
    });

    test('updates user status when app is idle but has metadata', () {
      expect(
        AppInitDecision.from(
          userState: AppUserState.idle,
          userMetadata: TestUserMetadata.create(
            appStatus: AppUserState.onboarding,
          ),
        ),
        AppInitDecision.updateUserStatus,
      );
    });

    test('does nothing on onboarding state', () {
      expect(
        AppInitDecision.from(
          userState: AppUserState.onboarding,
          userMetadata: TestUserMetadata.create(
            appStatus: AppUserState.onboarding,
          ),
        ),
        AppInitDecision.none,
      );
    });

    test('does nothing on active state', () {
      expect(
        AppInitDecision.from(
          userState: AppUserState.active,
          userMetadata: TestUserMetadata.create(
            appStatus: AppUserState.active,
          ),
        ),
        AppInitDecision.none,
      );
    });
  });
}
