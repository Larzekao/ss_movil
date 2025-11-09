import 'package:dio/dio.dart';
import 'package:ss_movil/core/env/env.dart';

/// Cliente Dio centralizado con configuración de timeouts y baseURL desde env
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Logging en debug
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) {
          // ignore: avoid_print
          print('[DIO] $obj');
        },
      ),
    );
  }

  /// Getter del cliente Dio
  Dio get client => _dio;

  /// Añadir interceptor personalizado (ej: AuthInterceptor)
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }
}
