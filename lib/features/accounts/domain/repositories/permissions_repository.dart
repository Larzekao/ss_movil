import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/permission.dart';

/// Repositorio abstracto para gestión de permisos (solo lectura)
///
/// Define la interfaz para operaciones de permisos sin especificar
/// la implementación (puede ser API REST, GraphQL, local, etc.)
abstract class PermissionsRepository {
  /// Lista permisos del sistema
  ///
  /// [search] - Término de búsqueda por módulo o código
  ///
  /// Returns: `Either<Failure, List<Permission>>`
  Future<Either<Failure, List<Permission>>> listPermissions({String? search});

  /// Obtiene un permiso específico por código
  ///
  /// [codigo] - Código del permiso (ej: "usuarios.crear")
  ///
  /// Returns: `Either<Failure, Permission>`
  Future<Either<Failure, Permission>> getPermission(String codigo);
}
