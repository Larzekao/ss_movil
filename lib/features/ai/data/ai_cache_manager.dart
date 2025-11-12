import '../domain/ai_models.dart';

/// Sistema de caché en memoria para respuestas de IA
///
/// Mantiene en memoria:
/// - Último AiDashboardResponse
/// - Último AiForecastResponse por categoría (incluyendo forecast general)
class AiCacheManager {
  static final AiCacheManager _instance = AiCacheManager._internal();
  factory AiCacheManager() => _instance;
  AiCacheManager._internal();

  // Cache de dashboard
  AiDashboardResponse? _cachedDashboard;
  DateTime? _dashboardCacheTime;
  final Duration _dashboardCacheDuration = const Duration(minutes: 5);

  // Cache de forecasts por categoría (key: categoryId o 'general')
  final Map<String, AiForecastResponse> _cachedForecasts = {};
  final Map<String, DateTime> _forecastCacheTimes = {};
  final Duration _forecastCacheDuration = const Duration(minutes: 10);

  /// Guarda el dashboard en caché
  void cacheDashboard(AiDashboardResponse dashboard) {
    _cachedDashboard = dashboard;
    _dashboardCacheTime = DateTime.now();
  }

  /// Obtiene el dashboard del caché si es válido
  AiDashboardResponse? getCachedDashboard() {
    if (_cachedDashboard == null || _dashboardCacheTime == null) {
      return null;
    }

    final age = DateTime.now().difference(_dashboardCacheTime!);
    if (age > _dashboardCacheDuration) {
      // Caché expirado
      _cachedDashboard = null;
      _dashboardCacheTime = null;
      return null;
    }

    return _cachedDashboard;
  }

  /// Guarda un forecast en caché
  ///
  /// [forecast] La respuesta del forecast
  /// [categoryId] ID de la categoría o null para forecast general
  void cacheForecast(AiForecastResponse forecast, {String? categoryId}) {
    final key = categoryId ?? 'general';
    _cachedForecasts[key] = forecast;
    _forecastCacheTimes[key] = DateTime.now();
  }

  /// Obtiene un forecast del caché si es válido
  ///
  /// [categoryId] ID de la categoría o null para forecast general
  AiForecastResponse? getCachedForecast({String? categoryId}) {
    final key = categoryId ?? 'general';

    final forecast = _cachedForecasts[key];
    final cacheTime = _forecastCacheTimes[key];

    if (forecast == null || cacheTime == null) {
      return null;
    }

    final age = DateTime.now().difference(cacheTime);
    if (age > _forecastCacheDuration) {
      // Caché expirado
      _cachedForecasts.remove(key);
      _forecastCacheTimes.remove(key);
      return null;
    }

    return forecast;
  }

  /// Invalida el caché del dashboard
  void invalidateDashboard() {
    _cachedDashboard = null;
    _dashboardCacheTime = null;
  }

  /// Invalida el caché de un forecast específico
  void invalidateForecast({String? categoryId}) {
    final key = categoryId ?? 'general';
    _cachedForecasts.remove(key);
    _forecastCacheTimes.remove(key);
  }

  /// Invalida todos los forecasts
  void invalidateAllForecasts() {
    _cachedForecasts.clear();
    _forecastCacheTimes.clear();
  }

  /// Limpia todo el caché
  void clearAll() {
    invalidateDashboard();
    invalidateAllForecasts();
  }

  /// Obtiene información del estado del caché (útil para debugging)
  Map<String, dynamic> getCacheInfo() {
    return {
      'dashboard': {
        'cached': _cachedDashboard != null,
        'age_seconds': _dashboardCacheTime != null
            ? DateTime.now().difference(_dashboardCacheTime!).inSeconds
            : null,
      },
      'forecasts': {
        'count': _cachedForecasts.length,
        'keys': _cachedForecasts.keys.toList(),
        'ages': _forecastCacheTimes.map(
          (key, time) =>
              MapEntry(key, DateTime.now().difference(time).inSeconds),
        ),
      },
    };
  }

  /// Verifica si un forecast está en caché y válido
  bool hasCachedForecast({String? categoryId}) {
    return getCachedForecast(categoryId: categoryId) != null;
  }

  /// Verifica si el dashboard está en caché y válido
  bool hasCachedDashboard() {
    return getCachedDashboard() != null;
  }
}
