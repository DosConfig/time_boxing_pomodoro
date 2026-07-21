import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/datasources/firebase_auth_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/delete_account.dart';
import '../domain/usecases/get_auth_session.dart';
import '../domain/usecases/sign_in_with_apple.dart';
import '../domain/usecases/sign_in_with_google.dart';
import '../domain/usecases/sign_out.dart';

part 'auth_providers.g.dart';

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
SignInWithGoogleUseCase signInWithGoogleUseCase(Ref ref) {
  return SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));
}

@Riverpod(keepAlive: true)
SignOutUseCase signOutUseCase(Ref ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
}

@Riverpod(keepAlive: true)
DeleteAccountUseCase deleteAccountUseCase(Ref ref) {
  return DeleteAccountUseCase(ref.watch(authRepositoryProvider));
}
