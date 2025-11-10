import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ss_movil/features/products/infrastructure/dtos/product_dto.dart';
import 'package:ss_movil/features/products/infrastructure/dtos/paged_dto.dart';

/// Remote DataSource para Products (Infrastructure)
abstract class ProductsRemoteDataSource {
  /// Lista productos paginados con filtros opcionales
  Future<PagedDto<ProductDto>> listProducts({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    String? brandId,
    double? minPrice,
    double? maxPrice,
    bool? isActive,
    String? orderBy,
  });

  /// Obtiene un producto por slug
  Future<ProductDto> getProduct(String slug);

  /// Crea un nuevo producto
  Future<ProductDto> createProduct(CreateProductDto dto);

  /// Actualiza un producto existente
  Future<ProductDto> updateProduct(String id, UpdateProductDto dto);

  /// Elimina un producto
  Future<void> deleteProduct(String id);
}

/// Implementación del ProductsRemoteDataSource
class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final Dio _dio;

  const ProductsRemoteDataSourceImpl(this._dio);

  @override
  Future<PagedDto<ProductDto>> listProducts({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    String? brandId,
    double? minPrice,
    double? maxPrice,
    bool? isActive,
    String? orderBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null) 'categoria': categoryId,
        if (brandId != null) 'marca': brandId,
        if (minPrice != null) 'precio_min': minPrice,
        if (maxPrice != null) 'precio_max': maxPrice,
        if (isActive != null) 'activa': isActive,
        if (orderBy != null) 'ordering': orderBy,
      };

      final response = await _dio.get(
        '/products/prendas/',
        queryParameters: queryParams,
      );

      return PagedDto<ProductDto>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => ProductDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProductDto> getProduct(String slug) async {
    try {
      final response = await _dio.get('/products/prendas/$slug/');
      return ProductDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProductDto> createProduct(CreateProductDto dto) async {
    try {
      // Si no hay imagen, enviar como JSON normal
      if (!dto.hasImage) {
        final response = await _dio.post(
          '/products/prendas/',
          data: dto.toJson(),
        );
        return ProductDto.fromJson(response.data as Map<String, dynamic>);
      }

      // Si hay imagen, enviar como multipart/form-data
      final formData = FormData();

      // Agregar campos de texto
      formData.fields.addAll([
        MapEntry('nombre', dto.nombre),
        MapEntry('descripcion', dto.descripcion),
        MapEntry('precio', dto.precio), // Ya es String
        MapEntry('stock', dto.stock.toString()),
        MapEntry('codigo', dto.codigo),
        MapEntry('marca_id', dto.brandId),
        MapEntry(
          'categoria_ids',
          dto.categoryId,
        ), // Backend espera categoria_ids
      ]);

      // Agregar campos opcionales si existen
      if (dto.material != null) {
        formData.fields.add(MapEntry('material', dto.material!));
      }
      if (dto.genero != null) {
        formData.fields.add(MapEntry('genero', dto.genero!));
      }
      if (dto.temporada != null) {
        formData.fields.add(MapEntry('temporada', dto.temporada!));
      }
      if (dto.color != null) {
        formData.fields.add(MapEntry('color', dto.color!));
      }

      // Agregar tallas si existen
      for (final talla in dto.sizeIds) {
        formData.fields.add(MapEntry('talla_ids', talla));
      }

      // Agregar archivo de imagen
      if (dto.imagenPath != null && dto.imagenPath!.isNotEmpty) {
        final imageFile = File(dto.imagenPath!);
        if (await imageFile.exists()) {
          final fileName = imageFile.path.split('/').last;
          formData.files.add(
            MapEntry(
              'imagen',
              await MultipartFile.fromFile(imageFile.path, filename: fileName),
            ),
          );
        }
      }

      final response = await _dio.post('/products/prendas/', data: formData);

      return ProductDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProductDto> updateProduct(String id, UpdateProductDto dto) async {
    try {
      final response = await _dio.patch(
        '/products/prendas/$id/',
        data: dto.toJson(),
      );

      return ProductDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('/products/prendas/$id/');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Maneja errores de Dio y los convierte a excepciones específicas
  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      // Manejar errores de validación (400, 422)
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

      // Manejar errores de autenticación (401, 403)
      if (statusCode == 401) {
        return AuthenticationException('No autorizado');
      }

      if (statusCode == 403) {
        return AuthenticationException(
          'Sin permisos para realizar esta acción',
        );
      }

      // Manejar error de servidor (500+)
      if (statusCode != null && statusCode >= 500) {
        return ServerException('Error del servidor');
      }

      // Error no encontrado (404)
      if (statusCode == 404) {
        return NotFoundException('Producto no encontrado');
      }
    }

    // Error de red
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return NetworkException('Tiempo de espera agotado');
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException('Error de conexión. Verifica tu internet');
    }

    return NetworkException('Error de red: ${error.message}');
  }
}

/// Excepciones específicas
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  @override
  String toString() => message;
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}
