import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/auth_session.dart';
import '../../di/auth_providers.dart';

export '../../di/auth_providers.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthActionController extends _$AuthActionController {
  @override
  bool build() => false;

  bool begin() {
    if (state) return false;
    state = true;
    return true;
  }

  void complete() => state = false;
}

@riverpod
class AuthController extends _$AuthController {
  static const _interactiveSignInTimeout = Duration(minutes: 2);

  @override
  Future<AuthSession> build() {
    return ref.watch(getAuthSessionUseCaseProvider).call();
  }

  Future<AuthSession> signInWithApple() async {
    return _runInteractiveSignIn(
      () => ref.read(signInWithAppleUseCaseProvider).call(),
    );
  }

  Future<AuthSession> signInWithGoogle() async {
    return _runInteractiveSignIn(
      () => ref.read(signInWithGoogleUseCaseProvider).call(),
    );
  }

  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _runInteractiveSignIn(
      () => ref
          .read(signInWithEmailUseCaseProvider)
          .call(email: email, password: password),
    );
  }

  Future<AuthSession> _runInteractiveSignIn(
    Future<AuthSession> Function() signIn,
  ) async {
    final fallback = state.value ?? const AuthSession(isConfigured: true);
    final actionController = ref.read(authActionControllerProvider.notifier);
    if (!actionController.begin()) return fallback;

    try {
      final session = await signIn().timeout(_interactiveSignInTimeout);
      state = AsyncData(session);
      return session;
    } catch (_) {
      state = AsyncData(fallback);
      return fallback;
    } finally {
      actionController.complete();
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(signOutUseCaseProvider).call();
    } finally {
      state = const AsyncData(AuthSession(isConfigured: true));
    }
  }

  Future<bool> deleteAccount() async {
    final previous = state.asData?.value;
    state = const AsyncLoading();
    try {
      final deleted = await ref.read(deleteAccountUseCaseProvider).call();
      if (deleted) {
        state = const AsyncData(AuthSession(isConfigured: true));
        return true;
      }

      state = AsyncData(
        previous ?? await ref.read(getAuthSessionUseCaseProvider).call(),
      );
      return false;
    } catch (_) {
      state = AsyncData(
        previous ?? await ref.read(getAuthSessionUseCaseProvider).call(),
      );
      return false;
    }
  }
}
