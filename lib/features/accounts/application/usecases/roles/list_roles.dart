import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/role.dart';
import 'package:ss_movil/features/accounts/domain/repositories/roles_repository.dart';

/// Caso de uso para obtener lista de roles
class ListRoles {
  final RolesRepository repository;

  ListRoles(this.repository);

  /// Ejecuta el caso de uso
  ///
  /// [search] - Término de búsqueda por nombre
  ///
  /// Returns: `Either<Failure, List<Role>>`
  Future<Either<Failure, List<Role>>> call({String? search}) {
    return repository.listRoles(search: search);
  }
}
