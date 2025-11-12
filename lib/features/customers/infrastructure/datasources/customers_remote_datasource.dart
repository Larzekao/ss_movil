import 'package:dio/dio.dart';
import 'package:ss_movil/core/exceptions/app_exceptions.dart';
import 'package:ss_movil/features/customers/infrastructure/models/cliente_dto.dart';
import 'package:ss_movil/features/customers/infrastructure/models/direccion_dto.dart';
import 'package:ss_movil/features/customers/infrastructure/models/preferencias_dto.dart';

// Endpoints
const String kMe = '/auth/users/me/';
const String kAddresses = '/customers/direcciones/';
const String kAddressesPrincipal = '/customers/direcciones/set-principal/';
const String kPreferences = '/customers/preferencias/';
const String kFavorites = '/customers/favoritos/';

class CustomersRemoteDatasource {
  final Dio dio;

  CustomersRemoteDatasource(this.dio);

  // Direcciones
  Future<List<DireccionDto>> listAddresses() async {
    try {
      final response = await dio.get(kAddresses);
      final List<dynamic> data = response.data is List
          ? response.data
          : response.data['data'] ?? [];
      return data
          .map((e) => DireccionDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Error al listar direcciones: $e');
    }
  }

  Future<DireccionDto> createAddress({
    required String etiqueta,
    required String direccionCompleta,
  }) async {
    try {
      final response = await dio.post(
        kAddresses,
        data: {'etiqueta': etiqueta, 'direccionCompleta': direccionCompleta},
      );
      return DireccionDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Error al crear dirección: $e');
    }
  }

  Future<DireccionDto> updateAddress({
    required int id,
    required String etiqueta,
    required String direccionCompleta,
  }) async {
    try {
      final response = await dio.put(
        '$kAddresses$id/',
        data: {'etiqueta': etiqueta, 'direccionCompleta': direccionCompleta},
      );
      return DireccionDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Error al actualizar dirección: $e');
    }
  }

  Future<void> deleteAddress(int id) async {
    try {
      await dio.delete('$kAddresses$id/');
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Error al eliminar dirección: $e');
    }
  }

  Future<DireccionDto> setPrincipal(int id) async {
    try {
      final response = await dio.post(
        '$kAddresses$id/set-principal/',
        data: {},
      );
      return DireccionDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Error al establecer dirección principal: $e');
    }
  }

  // Perfil
  Future<ClienteDto> getMe() async {
    try {
      final response = await dio.get(kMe);
      return ClienteDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Error al obtener perfil: $e');
    }
  }

  Future<ClienteDto> updateProfile({String? nombre, String? telefono}) async {
    try {
      final data = <String, dynamic>{};
      if (nombre != null) data['nombre'] = nombre;
      if (telefono != null) data['telefono'] = telefono;

      final response = await dio.patch(kMe, data: data);
      return ClienteDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Error al actualizar perfil: $e');
    }
  }

  // Preferencias
  Future<PreferenciasDto> getPreferences() async {
    try {
      final response = await dio.get(kPreferences);
      final data = response.data is Map
          ? response.data
          : response.data['data'] ?? {};
      return PreferenciasDto.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Error al obtener preferencias: $e');
    }
  }

  Future<PreferenciasDto> updatePreferences({
    bool? notificaciones,
    String? idioma,
    String? tallaFavorita,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (notificaciones != null) data['notificaciones'] = notificaciones;
      if (idioma != null) data['idioma'] = idioma;
      if (tallaFavorita != null) data['tallaFavorita'] = tallaFavorita;

      final response = await dio.patch(kPreferences, data: data);
      final responseData = response.data is Map
          ? response.data
          : response.data['data'] ?? {};
      return PreferenciasDto.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Error al actualizar preferencias: $e');
    }
  }

  // Favoritos
  Future<List<int>> listFavorites() async {
    try {
      final response = await dio.get(kFavorites);
      final List<dynamic> data = response.data is List
          ? response.data
          : response.data['data'] ?? [];
      return data.map((e) => (e is Map ? e['productId'] : e) as int).toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Error al listar favoritos: $e');
    }
  }

  Future<void> toggleFavorite(int productId) async {
    try {
      await dio.post('$kFavorites$productId/toggle/', data: {});
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException('Error al cambiar estado de favorito: $e');
    }
  }

  // Mapeo de excepciones Dio
  static AppException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException('Timeout en la conexión: ${e.message}');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message =
            e.response?.data['message'] ?? e.message ?? 'Error en la respuesta';
        if (statusCode == 401) {
          return UnauthorizedException('No autorizado: $message');
        } else if (statusCode == 404) {
          return NotFoundException('Recurso no encontrado: $message');
        } else if (statusCode == 400) {
          return ValidationException('Error de validación: $message');
        } else if (statusCode == 500) {
          return ServerException('Error del servidor: $message');
        }
        return ServerException('Error HTTP $statusCode: $message');
      case DioExceptionType.cancel:
        return NetworkException('Solicitud cancelada');
      case DioExceptionType.unknown:
        return NetworkException('Error desconocido: ${e.message}');
      default:
        return UnknownException('Error inesperado: ${e.message}');
    }
  }
}
