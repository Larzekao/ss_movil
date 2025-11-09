import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/user.dart';
import 'package:ss_movil/features/accounts/domain/repositories/users_repository.dart';
import 'package:ss_movil/features/accounts/infrastructure/datasources/users_remote_datasource.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/create_user_dto.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/update_user_dto.dart';

/// Implementación del repositorio de usuarios
class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;

  UsersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PagedUsers>> listUsers({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? roleId,
    bool? isActive,
  }) async {
    try {
      final pagedDto = await remoteDataSource.listUsers(
        page: page,
        pageSize: pageSize,
        search: search,
        roleId: roleId,
        isActive: isActive,
      );

      final users = pagedDto.results.map((dto) => dto.toEntity()).toList();

      return Right(
        PagedUsers(
          count: pagedDto.count,
          next: pagedDto.next,
          previous: pagedDto.previous,
          results: users,
        ),
      );
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al listar usuarios: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getUser(String userId) async {
    try {
      final userDto = await remoteDataSource.getUser(userId);
      return Right(userDto.toEntity());
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al obtener usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> createUser({
    required String email,
    required String password,
    required String passwordConfirm,
    required String nombre,
    required String apellido,
    String? telefono,
    required String roleId,
    String? codigoEmpleado,
    String? fotoPerfil,
  }) async {
    try {
      final dto = CreateUserDto(
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        roleId: roleId,
        codigoEmpleado: codigoEmpleado,
        fotoPerfil: fotoPerfil,
      );
      final userDto = await remoteDataSource.createUser(dto);
      return Right(userDto.toEntity());
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al crear usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> updateUser({
    required String userId,
    String? email,
    String? password,
    String? nombre,
    String? apellido,
    String? telefono,
    String? roleId,
    String? codigoEmpleado,
    String? fotoPerfil,
  }) async {
    try {
      final dto = UpdateUserDto(
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        roleId: roleId,
        codigoEmpleado: codigoEmpleado,
        fotoPerfil: fotoPerfil,
      );
      final userDto = await remoteDataSource.updateUser(userId, dto);
      return Right(userDto.toEntity());
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al actualizar usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> toggleActiveUser({
    required String userId,
    required bool isActive,
  }) async {
    try {
      final userDto = await remoteDataSource.toggleActiveUser(
        userId: userId,
        isActive: isActive,
      );
      return Right(userDto.toEntity());
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al cambiar estado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    try {
      await remoteDataSource.deleteUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al eliminar usuario: $e'));
    }
  }
}
