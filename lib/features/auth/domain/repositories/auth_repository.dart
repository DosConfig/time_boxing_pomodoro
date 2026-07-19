import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> currentSession();
  Future<AuthSession> signInWithApple();
  Future<void> signOut();
}
