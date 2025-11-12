import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/storage/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Proveedor para FlutterSecureStorage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Proveedor para TokenStorage
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return TokenStorage(storage);
});

/// Proveedor para Dio con interceptores
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
    ),
  );

  final tokenStorage = ref.watch(tokenStorageProvider);

  // Interceptor para agregar token
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Intenta refrescar el token
          final refreshToken = await tokenStorage.getRefreshToken();
          if (refreshToken != null) {
            try {
              final response = await dio.post(
                '/auth/refresh/',
                data: {'refresh': refreshToken},
              );
              final newAccessToken = response.data['access'];
              await tokenStorage.setAccessToken(newAccessToken);

              // Reintenta la solicitud original
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              return handler.resolve(
                await dio.request(
                  error.requestOptions.path,
                  options: Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                  ),
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                ),
              );
            } catch (e) {
              // Si falla el refresh, borra tokens y redirige a login
              await tokenStorage.clearTokens();
              return handler.next(error);
            }
          } else {
            // Sin refresh token, borra tokens
            await tokenStorage.clearTokens();
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});
