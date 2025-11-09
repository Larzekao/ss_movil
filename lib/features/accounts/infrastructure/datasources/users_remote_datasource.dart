import 'package:dio/dio.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/user_dto.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/paged_dto.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/create_user_dto.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/update_user_dto.dart';

/// Datasource remoto para operaciones CRUD de usuarios
///
/// Consume la API REST de Django en /api/auth/users/
class UsersRemoteDataSource {
  final Dio _dio;

  UsersRemoteDataSource(this._dio);

  /// Lista usuarios con paginación y filtros
  ///
  /// GET /api/auth/users/?page=1&page_size=20&search=query&rol=id&activo=true
  Future<PagedDto<UserDto>> listUsers({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? roleId,
    bool? isActive,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'page_size': pageSize};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (roleId != null) {
      queryParams['rol'] = roleId;
    }

    if (isActive != null) {
      queryParams['activo'] = isActive;
    }

    final response = await _dio.get(
      '/auth/users/',
      queryParameters: queryParams,
    );

    return PagedDto.fromJson(
      response.data as Map<String, dynamic>,
      (json) => UserDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Obtiene un usuario por ID
  ///
  /// GET /api/auth/users/{id}/
  Future<UserDto> getUser(String userId) async {
    final response = await _dio.get('/auth/users/$userId/');
    return UserDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// Crea un nuevo usuario
  ///
  /// POST /api/auth/register/
  Future<UserDto> createUser(CreateUserDto dto) async {
    final response = await _dio.post('/auth/register/', data: dto.toJson());

    // El endpoint de register devuelve {user, access, refresh}
    // Extraemos solo el user
    final data = response.data as Map<String, dynamic>;
    return UserDto.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Actualiza un usuario
  ///
  /// PATCH /api/auth/users/{id}/
  Future<UserDto> updateUser(String userId, UpdateUserDto dto) async {
    final response = await _dio.patch(
      '/auth/users/$userId/',
      data: dto.toJson(),
    );
    return UserDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// Activa o desactiva un usuario
  ///
  /// PATCH /api/auth/users/{id}/
  Future<UserDto> toggleActiveUser({
    required String userId,
    required bool isActive,
  }) async {
    final response = await _dio.patch(
      '/auth/users/$userId/',
      data: {'activo': isActive},
    );
    return UserDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// Elimina un usuario (hard delete)
  ///
  /// DELETE /api/auth/users/{id}/
  Future<void> deleteUser(String userId) async {
    await _dio.delete('/auth/users/$userId/');
  }
}
