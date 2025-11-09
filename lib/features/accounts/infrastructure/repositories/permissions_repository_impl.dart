import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/permission.dart';
import 'package:ss_movil/features/accounts/domain/repositories/permissions_repository.dart';
import 'package:ss_movil/features/accounts/infrastructure/datasources/permissions_remote_datasource.dart';

/// Implementación del repositorio de Permisos
class PermissionsRepositoryImpl implements PermissionsRepository {
  final PermissionsRemoteDataSource remoteDataSource;

  PermissionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Permission>>> listPermissions({
    String? search,
  }) async {
    try {
      final permissionsDto = await remoteDataSource.listPermissions(
        search: search,
      );
      return Right(permissionsDto.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al obtener permisos: $e'));
    }
  }

  @override
  Future<Either<Failure, Permission>> getPermission(String codigo) async {
    try {
      final permissionDto = await remoteDataSource.getPermission(codigo);
      return Right(permissionDto.toEntity());
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al obtener permiso: $e'));
    }
  }
}
