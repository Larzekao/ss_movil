import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/user.dart';
import 'package:ss_movil/features/accounts/domain/repositories/users_repository.dart';

/// Caso de uso para listar usuarios con paginación y filtros
class ListUsers {
  final UsersRepository repository;

  ListUsers(this.repository);

  /// Ejecuta el caso de uso
  ///
  /// [page] - Número de página (empezando en 1)
  /// [pageSize] - Cantidad de usuarios por página
  /// [search] - Término de búsqueda (nombre, email)
  /// [roleId] - Filtrar por ID de rol
  /// [isActive] - Filtrar por estado activo/inactivo
  Future<Either<Failure, PagedUsers>> call({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? roleId,
    bool? isActive,
  }) {
    return repository.listUsers(
      page: page,
      pageSize: pageSize,
      search: search,
      roleId: roleId,
      isActive: isActive,
    );
  }
}
