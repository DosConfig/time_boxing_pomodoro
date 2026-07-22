import 'dart:async';

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

  test('publishes the session returned by email sign-in', () async {
    final repository = _FakeAuthRepository(
      session: const AuthSession(isConfigured: true),
      emailSession: signedInSession,
      deleteResult: false,
    );
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    final session = await container
        .read(authControllerProvider.notifier)
        .signInWithEmail(email: 'review@example.com', password: 'password');

    expect(session, signedInSession);
    expect(
      container.read(authControllerProvider).requireValue,
      signedInSession,
    );
  });

  test('leaves loading state when Google sign-in throws', () async {
    final repository = _FakeAuthRepository(
      session: const AuthSession(isConfigured: true),
      deleteResult: false,
      googleSignInError: StateError('native sign-in failed'),
    );
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    final session = await container
        .read(authControllerProvider.notifier)
        .signInWithGoogle();

    expect(session.isSignedIn, isFalse);
    expect(container.read(authControllerProvider).isLoading, isFalse);
    expect(
      container.read(authControllerProvider).requireValue,
      const AuthSession(isConfigured: true),
    );
  });

  test('keeps the signed-out session visible during Google sign-in', () async {
    final googleSignInCompleter = Completer<AuthSession>();
    final repository = _FakeAuthRepository(
      session: const AuthSession(isConfigured: true),
      deleteResult: false,
      googleSignInFuture: googleSignInCompleter.future,
    );
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final authSubscription = container.listen(
      authControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    final actionSubscription = container.listen(
      authActionControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(authSubscription.close);
    addTearDown(actionSubscription.close);

    await container.read(authControllerProvider.future);
    final pendingSignIn = container
        .read(authControllerProvider.notifier)
        .signInWithGoogle();
    await Future<void>.delayed(Duration.zero);

    final pendingState = container.read(authControllerProvider);
    expect(pendingState.isLoading, isFalse);
    expect(pendingState.hasValue, isTrue);
    expect(pendingState.value?.isSignedIn, isFalse);
    expect(container.read(authActionControllerProvider), isTrue);

    googleSignInCompleter.complete(signedInSession);
    expect(await pendingSignIn, signedInSession);
    expect(
      container.read(authControllerProvider).requireValue,
      signedInSession,
    );
    expect(container.read(authActionControllerProvider), isFalse);
  });
}

class _FakeAuthRepository implements AuthRepository {
  AuthSession session;
  final AuthSession? emailSession;
  final bool deleteResult;
  final Object? googleSignInError;
  final Future<AuthSession>? googleSignInFuture;

  _FakeAuthRepository({
    required this.session,
    this.emailSession,
    required this.deleteResult,
    this.googleSignInError,
    this.googleSignInFuture,
  });

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
  Future<AuthSession> signInWithGoogle() async {
    final error = googleSignInError;
    if (error != null) throw error;
    final future = googleSignInFuture;
    if (future != null) return future;
    return session;
  }

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    session = emailSession ?? session;
    return session;
  }

  @override
  Future<void> signOut() async {
    session = const AuthSession(isConfigured: true);
  }
}
