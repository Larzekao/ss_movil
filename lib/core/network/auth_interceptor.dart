import 'package:dio/dio.dart';
import 'package:ss_movil/core/storage/secure_storage.dart';

/// Interceptor para inyectar Authorization y manejar refresh automático
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorage _storage;
  bool _isRefreshing = false;
  final List<({RequestOptions request, ErrorInterceptorHandler handler})>
  _pendingRequests = [];

  AuthInterceptor(this._dio, this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Excluir rutas de autenticación
    if (options.path.contains('/auth/login/') ||
        options.path.contains('/auth/register/') ||
        options.path.contains('/auth/refresh/')) {
      return handler.next(options);
    }

    // Inyectar access token si existe
    final accessToken = await _storage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Solo intentar refresh si es 401 y no es la ruta de refresh
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/refresh/')) {
      // Evitar múltiples refreshes simultáneos
      if (_isRefreshing) {
        // Encolar request para reintentar después del refresh
        _pendingRequests.add((request: err.requestOptions, handler: handler));
        return;
      }

      _isRefreshing = true;

      try {
        // Obtener refresh token
        final refreshToken = await _storage.getRefreshToken();

        if (refreshToken == null) {
          // No hay refresh token, limpiar y rechazar
          await _storage.deleteTokens();
          _isRefreshing = false;
          return handler.reject(err);
        }

        // Intentar refresh
        final response = await _dio.post(
          '/auth/refresh/',
          data: {'refresh': refreshToken},
        );

        final newAccessToken = response.data['access'];

        // Guardar nuevo access token
        await _storage.saveAccessToken(newAccessToken);

        // Reintentar request original con nuevo token
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await _dio.fetch(err.requestOptions);

        // Reintentar requests pendientes
        for (final pending in _pendingRequests) {
          pending.request.headers['Authorization'] = 'Bearer $newAccessToken';
          try {
            final pendingResponse = await _dio.fetch(pending.request);
            pending.handler.resolve(pendingResponse);
          } catch (e) {
            pending.handler.reject(
              DioException(requestOptions: pending.request, error: e),
            );
          }
        }
        _pendingRequests.clear();

        _isRefreshing = false;
        return handler.resolve(retryResponse);
      } catch (refreshError) {
        // Refresh falló, limpiar tokens y rechazar
        await _storage.deleteTokens();
        _isRefreshing = false;
        _pendingRequests.clear();

        return handler.reject(err);
      }
    }

    return handler.next(err);
  }
}
