import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<AuthSession> currentSession() {
    return dataSource.currentSession();
  }

  @override
  Future<AuthSession> signInWithApple() {
    return dataSource.signInWithApple();
  }

  @override
  Future<AuthSession> signInWithGoogle() {
    return dataSource.signInWithGoogle();
  }

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) {
    return dataSource.signInWithEmail(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return dataSource.signOut();
  }

  @override
  Future<bool> deleteAccount() {
    return dataSource.deleteAccount();
  }
}
