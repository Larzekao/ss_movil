import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/role.dart';
import 'package:ss_movil/features/accounts/domain/repositories/roles_repository.dart';
import 'package:ss_movil/features/accounts/infrastructure/datasources/roles_remote_datasource.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/create_role_dto.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/update_role_dto.dart';

/// Implementación del repositorio de Roles
class RolesRepositoryImpl implements RolesRepository {
  final RolesRemoteDataSource remoteDataSource;

  RolesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Role>>> listRoles({String? search}) async {
    try {
      final rolesDto = await remoteDataSource.listRoles(search: search);
      return Right(rolesDto.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al obtener roles: $e'));
    }
  }

  @override
  Future<Either<Failure, Role>> getRole(String roleId) async {
    try {
      final roleDto = await remoteDataSource.getRole(roleId);
      return Right(roleDto.toEntity());
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al obtener rol: $e'));
    }
  }

  @override
  Future<Either<Failure, Role>> createRole({
    required String nombre,
    String? descripcion,
    required List<String> permisosIds,
  }) async {
    try {
      final dto = CreateRoleDto(
        nombre: nombre,
        descripcion: descripcion,
        permisosIds: permisosIds,
      );
      final roleDto = await remoteDataSource.createRole(dto);
      return Right(roleDto.toEntity());
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al crear rol: $e'));
    }
  }

  @override
  Future<Either<Failure, Role>> updateRole({
    required String roleId,
    String? nombre,
    String? descripcion,
    List<String>? permisosIds,
  }) async {
    try {
      final dto = UpdateRoleDto(
        nombre: nombre,
        descripcion: descripcion,
        permisosIds: permisosIds,
      );
      final roleDto = await remoteDataSource.updateRole(roleId, dto);
      return Right(roleDto.toEntity());
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al actualizar rol: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRole(String roleId) async {
    try {
      await remoteDataSource.deleteRole(roleId);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al eliminar rol: $e'));
    }
  }
}
