import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/role.dart';

/// Repositorio abstracto para gestión de roles (CRUD)
///
/// Define la interfaz para operaciones de roles sin especificar
/// la implementación (puede ser API REST, GraphQL, local, etc.)
abstract class RolesRepository {
  /// Lista roles del sistema
  ///
  /// [search] - Término de búsqueda por nombre
  ///
  /// Returns: `Either<Failure, List<Role>>`
  Future<Either<Failure, List<Role>>> listRoles({String? search});

  /// Obtiene un rol específico por ID
  ///
  /// [roleId] - ID del rol
  ///
  /// Returns: `Either<Failure, Role>`
  Future<Either<Failure, Role>> getRole(String roleId);

  /// Crea un nuevo rol
  ///
  /// [nombre] - Nombre del rol
  /// [descripcion] - Descripción del rol (opcional)
  /// [permisosIds] - Lista de IDs de permisos
  ///
  /// Returns: `Either<Failure, Role>`
  Future<Either<Failure, Role>> createRole({
    required String nombre,
    String? descripcion,
    required List<String> permisosIds,
  });

  /// Actualiza un rol existente
  ///
  /// [roleId] - ID del rol a actualizar
  /// Los demás parámetros son opcionales (solo se actualizan los proporcionados)
  ///
  /// Returns: `Either<Failure, Role>`
  Future<Either<Failure, Role>> updateRole({
    required String roleId,
    String? nombre,
    String? descripcion,
    List<String>? permisosIds,
  });

  /// Elimina un rol
  ///
  /// [roleId] - ID del rol a eliminar
  ///
  /// Returns: `Either<Failure, Unit>`
  Future<Either<Failure, Unit>> deleteRole(String roleId);
}
