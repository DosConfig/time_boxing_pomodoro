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
  Future<void> signOut() {
    return dataSource.signOut();
  }
}
