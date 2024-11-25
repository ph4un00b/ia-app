import 'package:lola_ai_app/features/App/init.dart';
import 'package:lola_ai_app/features/User/types.dart';
import 'package:lola_ai_app/features/User/user_settings.dart';
import 'package:test/test.dart';

extension TestUserMetadata on UserMetadata {
  static UserMetadata create({
    required UserState appStatus,
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
          userState: UserState.idle,
          userMetadata: null,
        ),
        AppInitDecision.createUserMetadata,
      );
    });

    test('updates user status when app is idle but has metadata', () {
      expect(
        AppInitDecision.from(
          userState: UserState.idle,
          userMetadata: TestUserMetadata.create(
            appStatus: UserState.onboarding,
          ),
        ),
        AppInitDecision.updateUserStatus,
      );
    });

    test('does nothing on onboarding state', () {
      expect(
        AppInitDecision.from(
          userState: UserState.onboarding,
          userMetadata: TestUserMetadata.create(
            appStatus: UserState.onboarding,
          ),
        ),
        AppInitDecision.none,
      );
    });

    test('does nothing on active state', () {
      expect(
        AppInitDecision.from(
          userState: UserState.active,
          userMetadata: TestUserMetadata.create(
            appStatus: UserState.active,
          ),
        ),
        AppInitDecision.none,
      );
    });
  });
}
