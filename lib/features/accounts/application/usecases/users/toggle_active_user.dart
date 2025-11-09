import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/user.dart';
import 'package:ss_movil/features/accounts/domain/repositories/users_repository.dart';

/// Caso de uso para activar/desactivar un usuario
class ToggleActiveUser {
  final UsersRepository repository;

  ToggleActiveUser(this.repository);

  /// Ejecuta el caso de uso
  ///
  /// [userId] - ID del usuario
  /// [isActive] - Nuevo estado (true = activo, false = inactivo)
  Future<Either<Failure, User>> call({
    required String userId,
    required bool isActive,
  }) {
    return repository.toggleActiveUser(userId: userId, isActive: isActive);
  }
}
