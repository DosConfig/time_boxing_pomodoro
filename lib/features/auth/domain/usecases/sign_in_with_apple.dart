import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class SignInWithAppleUseCase {
  final AuthRepository repository;

  SignInWithAppleUseCase(this.repository);

  Future<AuthSession> call() {
    return repository.signInWithApple();
  }
}
