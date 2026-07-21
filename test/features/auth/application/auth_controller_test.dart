import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_boxing_pomodoro/features/auth/application/auth_controller.dart';
import 'package:time_boxing_pomodoro/features/auth/domain/entities/auth_session.dart';
import 'package:time_boxing_pomodoro/features/auth/domain/repositories/auth_repository.dart';

void main() {
  const signedInSession = AuthSession(
    isConfigured: true,
    userId: 'user-1',
    email: 'person@example.com',
    providerId: 'google.com',
  );

  test(
    'publishes a signed-out session immediately after account deletion',
    () async {
      final repository = _FakeAuthRepository(
        session: signedInSession,
        deleteResult: true,
      );
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.future);
      final deleted = await container
          .read(authControllerProvider.notifier)
          .deleteAccount();

      expect(deleted, isTrue);
      final session = container.read(authControllerProvider).requireValue;
      expect(session.isConfigured, isTrue);
      expect(session.isSignedIn, isFalse);
    },
  );

  test('keeps the signed-in session when account deletion fails', () async {
    final repository = _FakeAuthRepository(
      session: signedInSession,
      deleteResult: false,
    );
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    final deleted = await container
        .read(authControllerProvider.notifier)
        .deleteAccount();

    expect(deleted, isFalse);
    expect(
      container.read(authControllerProvider).requireValue,
      signedInSession,
    );
  });
}

class _FakeAuthRepository implements AuthRepository {
  AuthSession session;
  final bool deleteResult;

  _FakeAuthRepository({required this.session, required this.deleteResult});

  @override
  Future<AuthSession> currentSession() async => session;

  @override
  Future<bool> deleteAccount() async {
    if (deleteResult) {
      session = const AuthSession(isConfigured: true);
    }
    return deleteResult;
  }

  @override
  Future<AuthSession> signInWithApple() async => session;

  @override
  Future<AuthSession> signInWithGoogle() async => session;

  @override
  Future<void> signOut() async {
    session = const AuthSession(isConfigured: true);
  }
}
