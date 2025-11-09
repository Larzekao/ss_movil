import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/repositories/roles_repository.dart';

/// Caso de uso para eliminar un rol
class DeleteRole {
  final RolesRepository repository;

  DeleteRole(this.repository);

  /// Ejecuta el caso de uso
  ///
  /// [roleId] - ID del rol a eliminar
  ///
  /// Returns: `Either<Failure, Unit>`
  Future<Either<Failure, Unit>> call(String roleId) {
    return repository.deleteRole(roleId);
  }
}
