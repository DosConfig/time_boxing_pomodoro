import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailUseCase {
  final AuthRepository repository;

  SignInWithEmailUseCase(this.repository);

  Future<AuthSession> call({required String email, required String password}) {
    return repository.signInWithEmail(email: email, password: password);
  }
}
