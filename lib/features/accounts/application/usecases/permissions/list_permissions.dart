import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/permission.dart';
import 'package:ss_movil/features/accounts/domain/repositories/permissions_repository.dart';

/// Caso de uso para obtener lista de permisos
class ListPermissions {
  final PermissionsRepository repository;

  ListPermissions(this.repository);

  /// Ejecuta el caso de uso
  ///
  /// [search] - Término de búsqueda por módulo o código
  ///
  /// Returns: `Either<Failure, List<Permission>>`
  Future<Either<Failure, List<Permission>>> call({String? search}) {
    return repository.listPermissions(search: search);
  }
}
