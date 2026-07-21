import '../repositories/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<bool> call() {
    return repository.deleteAccount();
  }
}
