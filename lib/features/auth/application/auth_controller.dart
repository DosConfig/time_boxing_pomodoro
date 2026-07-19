import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/datasources/firebase_auth_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/entities/auth_session.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/get_auth_session.dart';
import '../domain/usecases/sign_in_with_apple.dart';
import '../domain/usecases/sign_out.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
FirebaseAuthDataSource firebaseAuthDataSource(Ref ref) {
  return FirebaseAuthDataSource();
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(firebaseAuthDataSourceProvider));
}

@Riverpod(keepAlive: true)
GetAuthSessionUseCase getAuthSessionUseCase(Ref ref) {
  return GetAuthSessionUseCase(ref.watch(authRepositoryProvider));
}

@Riverpod(keepAlive: true)
SignInWithAppleUseCase signInWithAppleUseCase(Ref ref) {
  return SignInWithAppleUseCase(ref.watch(authRepositoryProvider));
}

@Riverpod(keepAlive: true)
SignOutUseCase signOutUseCase(Ref ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
}

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

  Future<void> signOut() async {
    state = const AsyncLoading();
    await ref.read(signOutUseCaseProvider).call();
    state = AsyncData(await ref.read(getAuthSessionUseCaseProvider).call());
  }
}
