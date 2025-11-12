import 'package:dio/dio.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/core/storage/secure_storage.dart';
import 'package:ss_movil/features/accounts/domain/entities/user.dart';
import 'package:ss_movil/features/accounts/domain/repositories/auth_repository.dart';
import 'package:ss_movil/features/accounts/infrastructure/datasources/auth_remote_datasource.dart';

/// Implementación del repositorio de autenticación (Infrastructure)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final SecureStorage _storage;

  AuthRepositoryImpl(this._dataSource, this._storage);

  @override
  Future<({User? user, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginResponse = await _dataSource.login(
        email: email,
        password: password,
      );

      // Guardar tokens
      await _storage.saveAccessToken(loginResponse.access);
      await _storage.saveRefreshToken(loginResponse.refresh);

      // Mapear DTO a entidad
      final user = loginResponse.user.toEntity();

      return (user: user, failure: null);
    } on DioException catch (e) {
      return (user: null, failure: _handleDioError(e));
    } catch (e) {
      return (user: null, failure: Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<({User? user, Failure? failure})> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    String? telefono,
  }) async {
    try {
      final userDto = await _dataSource.register(
        email: email,
        password: password,
        passwordConfirm: password,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
      );

      final user = userDto.toEntity();

      return (user: user, failure: null);
    } on DioException catch (e) {
      return (user: null, failure: _handleDioError(e));
    } catch (e) {
      return (user: null, failure: Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<({User? user, Failure? failure})> me() async {
    try {
      final userDto = await _dataSource.me();
      final user = userDto.toEntity();

      return (user: user, failure: null);
    } on DioException catch (e) {
      return (user: null, failure: _handleDioError(e));
    } catch (e) {
      return (user: null, failure: Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<({String? accessToken, Failure? failure})> refresh({
    required String refreshToken,
  }) async {
    try {
      final refreshResponse = await _dataSource.refresh(
        refreshToken: refreshToken,
      );

      // Guardar nuevo access token
      await _storage.saveAccessToken(refreshResponse.access);

      return (accessToken: refreshResponse.access, failure: null);
    } on DioException catch (e) {
      return (accessToken: null, failure: _handleDioError(e));
    } catch (e) {
      return (
        accessToken: null,
        failure: Failure.unknown(message: e.toString()),
      );
    }
  }

  @override
  Future<void> logout() async {
    await _storage.deleteTokens();
  }

  /// Maneja errores de Dio y los convierte en Failures
  Failure _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final message = _extractErrorMessage(e.response!.data);

      if (statusCode == 401 || statusCode == 403) {
        return Failure.auth(message: message, statusCode: statusCode);
      } else if (statusCode! >= 500) {
        return Failure.server(message: message, statusCode: statusCode);
      } else if (statusCode == 400) {
        return Failure.validation(
          message: message,
          errors: _extractValidationErrors(e.response!.data),
        );
      }
    }

    // Error de red (timeout, no internet, etc)
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const Failure.network(message: 'Timeout: El servidor no responde');
    }

    if (e.type == DioExceptionType.connectionError) {
      return const Failure.network(
        message: 'Error de conexión: Verifica tu internet',
      );
    }

    return Failure.network(message: e.message ?? 'Error desconocido de red');
  }

  /// Extrae el mensaje de error del response data
  String _extractErrorMessage(dynamic data) {
    if (data is Map) {
      // Buscar mensaje en varios campos comunes
      if (data['message'] != null) return data['message'].toString();
      if (data['detail'] != null) return data['detail'].toString();
      if (data['error'] != null) return data['error'].toString();

      // Si hay errores de validación, tomar el primero
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
      }
    }

    return 'Error en la solicitud';
  }

  /// Extrae errores de validación
  Map<String, List<String>>? _extractValidationErrors(dynamic data) {
    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      return errors.map((key, value) {
        if (value is List) {
          return MapEntry(
            key.toString(),
            value.map((e) => e.toString()).toList(),
          );
        }
        return MapEntry(key.toString(), [value.toString()]);
      });
    }
    return null;
  }
}
