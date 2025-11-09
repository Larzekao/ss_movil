import 'package:dio/dio.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/permission_dto.dart';

/// Datasource remoto para permisos
class PermissionsRemoteDataSource {
  final Dio _dio;

  PermissionsRemoteDataSource(this._dio);

  /// Obtiene todos los permisos disponibles
  Future<List<PermissionDto>> getPermissions() async {
    try {
      final response = await _dio.get('/auth/permissions/');

      final data = response.data;
      if (data is List) {
        return data
            .map((json) => PermissionDto.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data.containsKey('results')) {
        return ((data['results'] as List)
            .map((json) => PermissionDto.fromJson(json as Map<String, dynamic>))
            .toList());
      }

      return [];
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  /// Lista permisos con búsqueda opcional
  ///
  /// [search] - Término de búsqueda por módulo o código
  Future<List<PermissionDto>> listPermissions({String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        '/auth/permissions/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data;
      if (data is List) {
        return data
            .map((json) => PermissionDto.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data.containsKey('results')) {
        return ((data['results'] as List)
            .map((json) => PermissionDto.fromJson(json as Map<String, dynamic>))
            .toList());
      }

      return [];
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  /// Obtiene un permiso específico por código
  ///
  /// [codigo] - Código del permiso (ej: "usuarios.crear")
  Future<PermissionDto> getPermission(String codigo) async {
    try {
      final response = await _dio.get('/auth/permissions/$codigo/');
      return PermissionDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }
}
