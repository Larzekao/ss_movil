import 'package:dio/dio.dart';
import 'ai_api.dart';
import 'ai_cache_manager.dart';
import 'ai_rate_limiter.dart';
import 'ai_fallback_data.dart';
import '../domain/ai_models.dart';

/// Repositorio para operaciones de Inteligencia Artificial
/// Envuelve AiApi y mapea errores HTTP a excepciones del dominio
///
/// Incluye:
/// - Rate limiting (1 llamada / 2s con backoff)
/// - Caché en memoria
/// - Fallbacks para 404/501
class AiRepository {
  final AiApi _api;
  final AiCacheManager _cache;
  final AiRateLimiter _rateLimiter;

  AiRepository(this._api)
    : _cache = AiCacheManager(),
      _rateLimiter = AiRateLimiter();

  /// Obtiene el dashboard de IA
  ///
  /// - Usa caché si está disponible y válido (5 min)
  /// - Aplica rate limiting (1 llamada / 2s)
  /// - Retorna fallback en caso de 404/501
  ///
  /// Throws:
  /// - [AiUnauthorizedException] si no está autenticado (401)
  /// - [AiBadRequestException] si los parámetros son inválidos (400)
  /// - [AiServerException] si hay error del servidor (500)
  /// - [AiNetworkException] si hay error de red
  Future<AiDashboardResponse> getDashboard({
    int? monthsBack,
    int? monthsForward,
    bool forceRefresh = false,
  }) async {
    // Verificar caché primero
    if (!forceRefresh) {
      final cached = _cache.getCachedDashboard();
      if (cached != null) {
        return cached;
      }
    }

    try {
      // Aplicar rate limiting con reintentos automáticos
      final response = await _rateLimiter.execute(
        'dashboard',
        () => _api.getDashboard(
          monthsBack: monthsBack,
          monthsForward: monthsForward,
        ),
      );

      // Guardar en caché
      _cache.cacheDashboard(response);
      return response;
    } catch (e) {
      final exception = _mapError(e);

      // Retornar fallback para errores 404/501/500 (si no hay modelo)
      if (exception is AiException) {
        final shouldUseFallback =
            exception.statusCode == 404 ||
            exception.statusCode == 501 ||
            (exception.statusCode == 500 &&
                exception.message.toLowerCase().contains('modelo'));

        if (shouldUseFallback) {
          final fallback = AiFallbackData.getFallbackDashboard();
          _cache.cacheDashboard(fallback);
          return fallback;
        }
      }

      throw exception;
    }
  }

  /// Genera predicción de ventas
  ///
  /// - Usa caché por categoría (10 min)
  /// - Aplica rate limiting (1 llamada / 2s)
  /// - Retorna fallback en caso de 404/501
  ///
  /// [nMonths] debe ser mayor a 0
  /// [categoria] es opcional para predicción específica
  ///
  /// Throws:
  /// - [AiUnauthorizedException] si no está autenticado (401)
  /// - [AiBadRequestException] si los parámetros son inválidos (400)
  /// - [AiServerException] si hay error del servidor (500)
  /// - [AiNetworkException] si hay error de red
  Future<AiForecastResponse> forecast({
    required int nMonths,
    String? categoria,
    bool forceRefresh = false,
  }) async {
    // Verificar caché primero
    if (!forceRefresh) {
      final cached = _cache.getCachedForecast(categoryId: categoria);
      if (cached != null) {
        return cached;
      }
    }

    try {
      // Aplicar rate limiting con reintentos automáticos
      final cacheKey = categoria != null ? 'forecast_$categoria' : 'forecast';
      final response = await _rateLimiter.execute(
        cacheKey,
        () => _api.forecast(nMonths: nMonths, categoria: categoria),
      );

      // Guardar en caché
      _cache.cacheForecast(response, categoryId: categoria);
      return response;
    } catch (e) {
      final exception = _mapError(e);

      // Retornar fallback para errores 404/501/500 (si no hay modelo)
      if (exception is AiException) {
        final shouldUseFallback =
            exception.statusCode == 404 ||
            exception.statusCode == 501 ||
            (exception.statusCode == 500 &&
                exception.message.toLowerCase().contains('modelo'));

        if (shouldUseFallback) {
          final fallback = AiFallbackData.getFallbackForecast(
            daysAhead: nMonths * 30,
            categoryId: categoria,
          );
          _cache.cacheForecast(fallback, categoryId: categoria);
          return fallback;
        }
      }

      throw exception;
    }
  }

  /// Obtiene el modelo activo
  ///
  /// Throws:
  /// - [AiUnauthorizedException] si no está autenticado (401)
  /// - [AiServerException] si hay error del servidor (500)
  /// - [AiNetworkException] si hay error de red
  Future<AiModelInfo> getActiveModel() async {
    try {
      return await _api.getActiveModel();
    } catch (e) {
      throw _mapError(e);
    }
  }

  /// Inicia entrenamiento de un nuevo modelo
  /// Este proceso puede tardar varios minutos
  ///
  /// Throws:
  /// - [AiUnauthorizedException] si no está autenticado (401)
  /// - [AiBadRequestException] si no hay datos suficientes (400)
  /// - [AiServerException] si hay error del servidor (500)
  /// - [AiNetworkException] si hay error de red
  Future<void> trainModel() async {
    try {
      await _api.trainModel();
    } catch (e) {
      throw _mapError(e);
    }
  }

  /// Lista todos los modelos disponibles
  ///
  /// Throws:
  /// - [AiUnauthorizedException] si no está autenticado (401)
  /// - [AiServerException] si hay error del servidor (500)
  /// - [AiNetworkException] si hay error de red
  Future<List<AiModelInfo>> listModels() async {
    try {
      return await _api.listModels();
    } catch (e) {
      throw _mapError(e);
    }
  }

  /// Obtiene historial de predicciones
  ///
  /// [limit] limita el número de resultados
  ///
  /// Throws:
  /// - [AiUnauthorizedException] si no está autenticado (401)
  /// - [AiServerException] si hay error del servidor (500)
  /// - [AiNetworkException] si hay error de red
  Future<List<PredictionHistoryItem>> getPredictionsHistory({
    int? limit,
  }) async {
    try {
      return await _api.getPredictionsHistory(limit: limit);
    } catch (e) {
      throw _mapError(e);
    }
  }

  /// Invalida el caché (útil después de entrenar un modelo)
  void invalidateCache() {
    _cache.clearAll();
  }

  /// Invalida solo el caché de forecasts
  void invalidateForecastCache({String? categoryId}) {
    if (categoryId != null) {
      _cache.invalidateForecast(categoryId: categoryId);
    } else {
      _cache.invalidateAllForecasts();
    }
  }

  /// Mapea errores de Dio a excepciones del dominio con mensajes amigables
  Exception _mapError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final message = _extractErrorMessage(error);

      switch (statusCode) {
        case 401:
          return AiException(
            'Sesión expirada. Inicia sesión nuevamente.',
            statusCode: 401,
            originalError: error,
          );
        case 403:
          return AiException(
            'No tienes permisos para acceder a esta función de IA.',
            statusCode: 403,
            originalError: error,
          );
        case 400:
          return AiBadRequestException(message);
        case 404:
          return AiException(
            'El servicio de IA no está disponible.',
            statusCode: 404,
            originalError: error,
          );
        case 429:
          return AiException(
            'Demasiadas solicitudes. Espera un momento.',
            statusCode: 429,
            originalError: error,
          );
        case 500:
          return AiException(
            'Error del servidor de IA.',
            statusCode: 500,
            originalError: error,
          );
        case 501:
          return AiException(
            'Esta función de IA aún no está implementada.',
            statusCode: 501,
            originalError: error,
          );
        case 502:
        case 503:
        case 504:
          return AiException(
            'El servidor de IA está temporalmente no disponible.',
            statusCode: statusCode,
            originalError: error,
          );
        default:
          // Errores de conexión (sin response)
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            return const AiNetworkException(
              'Tiempo de espera agotado. Verifica tu conexión.',
            );
          }
          if (error.type == DioExceptionType.connectionError) {
            return const AiNetworkException(
              'No se pudo conectar al servidor. Verifica tu conexión.',
            );
          }
          return AiException(
            message,
            statusCode: statusCode,
            originalError: error,
          );
      }
    }

    // Error desconocido
    return AiException(
      'Error inesperado: ${error.toString()}',
      originalError: error,
    );
  }

  /// Extrae el mensaje de error de la respuesta
  String _extractErrorMessage(DioException error) {
    try {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        // Intentar extraer mensaje del backend
        if (data.containsKey('detail')) {
          return data['detail'].toString();
        }
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
        if (data.containsKey('error')) {
          return data['error'].toString();
        }
      }
      return error.message ?? 'Error desconocido';
    } catch (_) {
      return error.message ?? 'Error desconocido';
    }
  }
}
