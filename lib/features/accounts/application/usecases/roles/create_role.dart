import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/role.dart';
import 'package:ss_movil/features/accounts/domain/repositories/roles_repository.dart';

/// Caso de uso para crear un nuevo rol
class CreateRole {
  final RolesRepository repository;

  CreateRole(this.repository);

  /// Ejecuta el caso de uso
  ///
  /// [nombre] - Nombre del rol
  /// [descripcion] - Descripción del rol (opcional)
  /// [permisosIds] - Lista de IDs de permisos
  ///
  /// Returns: `Either<Failure, Role>`
  Future<Either<Failure, Role>> call({
    required String nombre,
    String? descripcion,
    required List<String> permisosIds,
  }) {
    return repository.createRole(
      nombre: nombre,
      descripcion: descripcion,
      permisosIds: permisosIds,
    );
  }
}
