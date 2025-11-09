import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/role.dart';
import 'package:ss_movil/features/accounts/domain/repositories/roles_repository.dart';

/// Caso de uso para obtener un rol específico
class GetRole {
  final RolesRepository repository;

  GetRole(this.repository);

  /// Ejecuta el caso de uso
  ///
  /// [roleId] - ID del rol
  ///
  /// Returns: `Either<Failure, Role>`
  Future<Either<Failure, Role>> call(String roleId) {
    return repository.getRole(roleId);
  }
}
