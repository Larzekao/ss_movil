import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/role.dart';
import 'package:ss_movil/features/accounts/domain/repositories/roles_repository.dart';

/// Caso de uso para actualizar un rol existente
class UpdateRole {
  final RolesRepository repository;

  UpdateRole(this.repository);

  /// Ejecuta el caso de uso
  ///
  /// [roleId] - ID del rol a actualizar
  /// Los demás parámetros son opcionales (solo se actualizan los proporcionados)
  ///
  /// Returns: `Either<Failure, Role>`
  Future<Either<Failure, Role>> call({
    required String roleId,
    String? nombre,
    String? descripcion,
    List<String>? permisosIds,
  }) {
    return repository.updateRole(
      roleId: roleId,
      nombre: nombre,
      descripcion: descripcion,
      permisosIds: permisosIds,
    );
  }
}
