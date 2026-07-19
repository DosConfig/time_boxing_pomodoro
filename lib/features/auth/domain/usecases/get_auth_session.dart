import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class GetAuthSessionUseCase {
  final AuthRepository repository;

  GetAuthSessionUseCase(this.repository);

  Future<AuthSession> call() {
    return repository.currentSession();
  }
}
