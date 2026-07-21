import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../di/auth_providers.dart';
import '../domain/entities/auth_session.dart';

export '../di/auth_providers.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  Future<AuthSession> build() {
    return ref.watch(getAuthSessionUseCaseProvider).call();
  }

  Future<AuthSession> signInWithApple() async {
    state = const AsyncLoading();
    final session = await ref.read(signInWithAppleUseCaseProvider).call();
    state = AsyncData(session);
    return session;
  }

  Future<AuthSession> signInWithGoogle() async {
    state = const AsyncLoading();
    final session = await ref.read(signInWithGoogleUseCaseProvider).call();
    state = AsyncData(session);
    return session;
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
