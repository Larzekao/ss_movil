import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/repositories/users_repository.dart';

/// Caso de uso para eliminar un usuario
class DeleteUser {
  final UsersRepository repository;

  DeleteUser(this.repository);

  /// Ejecuta el caso de uso
  ///
  /// [userId] - ID del usuario a eliminar
  Future<Either<Failure, void>> call(String userId) {
    return repository.deleteUser(userId);
  }
}
