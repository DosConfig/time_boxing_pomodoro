import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> currentSession();
  Future<AuthSession> signInWithApple();
  Future<AuthSession> signInWithGoogle();
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<bool> deleteAccount();
}
