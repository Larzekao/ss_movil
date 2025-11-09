import 'package:dio/dio.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/role_dto.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/create_role_dto.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/update_role_dto.dart';

/// Datasource remoto para operaciones CRUD de roles
///
/// Consume la API REST de Django en /api/auth/roles/
class RolesRemoteDataSource {
  final Dio _dio;

  RolesRemoteDataSource(this._dio);

  /// Lista roles del sistema
  ///
  /// GET /api/auth/roles/?search=query
  Future<List<RoleDto>> listRoles({String? search}) async {
    final queryParams = <String, dynamic>{};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _dio.get(
      '/auth/roles/',
      queryParameters: queryParams,
    );

    // El endpoint devuelve una lista directa o paginada con 'results'
    final data = response.data;
    if (data is List) {
      return data
          .map((json) => RoleDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } else if (data is Map && data.containsKey('results')) {
      return ((data['results'] as List)
          .map((json) => RoleDto.fromJson(json as Map<String, dynamic>))
          .toList());
    }
    return [];
  }

  /// Obtiene un rol por ID
  ///
  /// GET /api/auth/roles/{id}/
  Future<RoleDto> getRole(String roleId) async {
    final response = await _dio.get('/auth/roles/$roleId/');
    return RoleDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// Crea un nuevo rol
  ///
  /// POST /api/auth/roles/
  Future<RoleDto> createRole(CreateRoleDto dto) async {
    final response = await _dio.post('/auth/roles/', data: dto.toJson());
    return RoleDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// Actualiza un rol
  ///
  /// PATCH /api/auth/roles/{id}/
  Future<RoleDto> updateRole(String roleId, UpdateRoleDto dto) async {
    final response = await _dio.patch(
      '/auth/roles/$roleId/',
      data: dto.toJson(),
    );
    return RoleDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// Elimina un rol
  ///
  /// DELETE /api/auth/roles/{id}/
  Future<void> deleteRole(String roleId) async {
    await _dio.delete('/auth/roles/$roleId/');
  }
}
