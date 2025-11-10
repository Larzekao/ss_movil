import 'package:dio/dio.dart';
import 'package:ss_movil/features/products/infrastructure/dtos/category_dto.dart';
import 'package:ss_movil/features/products/infrastructure/dtos/paged_dto.dart';

/// Remote DataSource para Categories (Infrastructure)
abstract class CategoriesRemoteDataSource {
  /// Lista categorías paginadas con filtros opcionales
  Future<PagedDto<CategoryDto>> listCategories({
    int page = 1,
    int limit = 10,
    String? search,
    String? parentId,
    bool? isActive,
    String? orderBy,
  });

  /// Obtiene una categoría por ID
  Future<CategoryDto> getCategory(String id);

  /// Crea una nueva categoría
  Future<CategoryDto> createCategory(CreateCategoryDto dto);

  /// Actualiza una categoría existente
  Future<CategoryDto> updateCategory(String id, UpdateCategoryDto dto);

  /// Elimina una categoría
  Future<void> deleteCategory(String id);

  /// Lista categorías principales (sin padre)
  Future<List<CategoryDto>> getRootCategories();

  /// Lista subcategorías de una categoría padre
  Future<List<CategoryDto>> getSubcategories(String parentId);
}

/// Implementación del CategoriesRemoteDataSource
class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  final Dio _dio;

  const CategoriesRemoteDataSourceImpl(this._dio);

  @override
  Future<PagedDto<CategoryDto>> listCategories({
    int page = 1,
    int limit = 10,
    String? search,
    String? parentId,
    bool? isActive,
    String? orderBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (parentId != null) 'categoria_padre_id': parentId,
        if (isActive != null) 'activo': isActive,
        if (orderBy != null) 'ordering': orderBy,
      };

      final response = await _dio.get(
        '/products/categorias/',
        queryParameters: queryParams,
      );

      return PagedDto<CategoryDto>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CategoryDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error al procesar categorías: $e');
    }
  }

  @override
  Future<CategoryDto> getCategory(String id) async {
    try {
      final response = await _dio.get('/products/categorias/$id/');
      return CategoryDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<CategoryDto> createCategory(CreateCategoryDto dto) async {
    try {
      final formData = FormData.fromMap(dto.toJson());

      final response = await _dio.post(
        '/products/categorias/',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return CategoryDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<CategoryDto> updateCategory(String id, UpdateCategoryDto dto) async {
    try {
      final formData = FormData.fromMap(dto.toJson());

      final response = await _dio.patch(
        '/products/categorias/$id/',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return CategoryDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _dio.delete('/products/categorias/$id/');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<CategoryDto>> getRootCategories() async {
    try {
      final response = await _dio.get(
        '/products/categorias/',
        queryParameters: {'categoria_padre_id': 'null'},
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => CategoryDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<CategoryDto>> getSubcategories(String parentId) async {
    try {
      final response = await _dio.get(
        '/products/categorias/',
        queryParameters: {'categoria_padre_id': parentId},
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => CategoryDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Manejo centralizado de errores Dio
  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      // Errores de validación (400, 422)
      if (statusCode == 400 || statusCode == 422) {
        if (data is Map<String, dynamic>) {
          final messages = <String>[];
          data.forEach((key, value) {
            if (value is List) {
              messages.addAll(value.map((e) => '$key: $e'));
            } else {
              messages.add('$key: $value');
            }
          });
          return ValidationException(messages.join(', '));
        }
      }

      // Errores de autenticación (401, 403)
      if (statusCode == 401) {
        return AuthenticationException('No autorizado');
      }

      if (statusCode == 403) {
        return AuthenticationException(
          'Sin permisos para realizar esta acción',
        );
      }

      // Error de servidor (500+)
      if (statusCode != null && statusCode >= 500) {
        return ServerException('Error del servidor');
      }

      // Error no encontrado (404)
      if (statusCode == 404) {
        return NotFoundException('Categoría no encontrada');
      }
    }

    // Error de red
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return NetworkException('Tiempo de espera agotado');
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException('Sin conexión a internet');
    }

    return Exception('Error desconocido: ${error.message}');
  }
}

// Excepciones personalizadas
class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
  @override
  String toString() => message;
}

class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException(this.message);
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
  @override
  String toString() => message;
}

/// DTO para crear categoría
class CreateCategoryDto {
  final String nombre;
  final String? descripcion;
  final String? imagen;
  final String? icono;
  final String? color;
  final String? parentId;
  final int orden;
  final bool activa;

  const CreateCategoryDto({
    required this.nombre,
    this.descripcion,
    this.imagen,
    this.icono,
    this.color,
    this.parentId,
    this.orden = 0,
    this.activa = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (imagen != null) 'imagen': imagen,
      if (icono != null) 'icono': icono,
      if (color != null) 'color': color,
      if (parentId != null) 'categoria_padre_id': parentId,
      'orden': orden,
      'activa': activa, // El backend usa 'activa'
    };
  }
}

/// DTO para actualizar categoría
class UpdateCategoryDto {
  final String? nombre;
  final String? descripcion;
  final String? imagen;
  final String? icono;
  final String? color;
  final String? parentId;
  final int? orden;
  final bool? activa;

  const UpdateCategoryDto({
    this.nombre,
    this.descripcion,
    this.imagen,
    this.icono,
    this.color,
    this.parentId,
    this.orden,
    this.activa,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (nombre != null) map['nombre'] = nombre;
    if (descripcion != null) map['descripcion'] = descripcion;
    if (imagen != null) map['imagen'] = imagen;
    if (icono != null) map['icono'] = icono;
    if (color != null) map['color'] = color;
    if (parentId != null) map['categoria_padre_id'] = parentId;
    if (orden != null) map['orden'] = orden;
    if (activa != null) map['activa'] = activa; // El backend usa 'activa'
    return map;
  }
}
