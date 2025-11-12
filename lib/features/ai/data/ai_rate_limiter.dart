/// Sistema de rate limiting para peticiones de IA
///
/// Implementa límite de 1 llamada cada 2 segundos con backoff exponencial
class AiRateLimiter {
  static final AiRateLimiter _instance = AiRateLimiter._internal();
  factory AiRateLimiter() => _instance;
  AiRateLimiter._internal();

  final Map<String, DateTime> _lastCallTimes = {};
  final Duration _minInterval = const Duration(seconds: 2);
  final Duration _backoffBase = const Duration(milliseconds: 500);
  final int _maxRetries = 2;

  /// Espera hasta que se pueda hacer una llamada respetando el rate limit
  ///
  /// [key] Identificador único de la operación (ej: 'forecast', 'dashboard')
  /// [retryCount] Número de reintentos (para backoff exponencial)
  Future<void> waitIfNeeded(String key, {int retryCount = 0}) async {
    final lastCall = _lastCallTimes[key];

    if (lastCall != null) {
      final timeSinceLastCall = DateTime.now().difference(lastCall);
      final requiredWait = _minInterval - timeSinceLastCall;

      if (requiredWait.isNegative == false) {
        // Aplicar backoff exponencial si es un reintento
        final backoffMultiplier = retryCount > 0
            ? (1 << retryCount)
            : 1; // 2^retryCount
        final totalWait = requiredWait + (_backoffBase * backoffMultiplier);

        await Future.delayed(totalWait);
      }
    }

    _lastCallTimes[key] = DateTime.now();
  }

  /// Ejecuta una operación con rate limiting y reintentos automáticos
  ///
  /// [key] Identificador único de la operación
  /// [operation] Función async que realiza la llamada a la API
  /// [retryCount] Contador interno de reintentos (no usar externamente)
  Future<T> execute<T>(
    String key,
    Future<T> Function() operation, {
    int retryCount = 0,
  }) async {
    if (retryCount > _maxRetries) {
      throw Exception('Máximo de reintentos alcanzado para operación: $key');
    }

    await waitIfNeeded(key, retryCount: retryCount);

    try {
      return await operation();
    } catch (e) {
      // Si es error de red o timeout, reintentar
      if (retryCount < _maxRetries && _shouldRetry(e)) {
        return execute(key, operation, retryCount: retryCount + 1);
      }
      rethrow;
    }
  }

  /// Determina si un error es recuperable y merece reintento
  bool _shouldRetry(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Reintentar en timeouts y errores de conexión
    return errorString.contains('timeout') ||
        errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('socket');
  }

  /// Limpia el historial de llamadas (útil para testing)
  void reset() {
    _lastCallTimes.clear();
  }

  /// Obtiene el tiempo restante hasta la próxima llamada permitida
  Duration? getTimeUntilNextCall(String key) {
    final lastCall = _lastCallTimes[key];
    if (lastCall == null) return Duration.zero;

    final timeSinceLastCall = DateTime.now().difference(lastCall);
    final remaining = _minInterval - timeSinceLastCall;

    return remaining.isNegative ? Duration.zero : remaining;
  }
}
