import '../domain/ai_models.dart';

/// Generador de respuestas de fallback para cuando el backend no está disponible
class AiFallbackData {
  /// Genera un dashboard básico de fallback
  static AiDashboardResponse getFallbackDashboard() {
    return AiDashboardResponse(
      activeModel: null,
      metrics: [
        MetricItem(
          label: 'Total Ventas',
          value: 'N/D',
          unit: 'Bs',
          trend: null,
        ),
        MetricItem(
          label: 'Predicción 30d',
          value: 'N/D',
          unit: 'Bs',
          trend: null,
        ),
        MetricItem(
          label: 'Precisión Modelo',
          value: 'N/D',
          unit: '%',
          trend: null,
        ),
        MetricItem(
          label: 'Último Entreno',
          value: 'N/D',
          unit: '',
          trend: null,
        ),
      ],
      recentPredictions: [],
    );
  }

  /// Genera un forecast básico de fallback
  static AiForecastResponse getFallbackForecast({
    int daysAhead = 30,
    String? categoryId,
    String? categoryName,
  }) {
    final now = DateTime.now();

    // Generar puntos de datos vacíos
    final forecastPoints = List.generate(daysAhead, (index) {
      return ForecastPoint(
        date: now.add(Duration(days: index + 1)),
        value: 0.0,
        lowerBound: 0.0,
        upperBound: 0.0,
        isHistorical: false,
      );
    });

    String message =
        'El servicio de predicción no está disponible actualmente.';
    if (categoryName != null) {
      message = 'Predicción para "$categoryName" no disponible.';
    }

    return AiForecastResponse(
      forecast: forecastPoints,
      kpis: {
        'total_historico': 0.0,
        'prediccion_total': 0.0,
        'variacion': 0.0,
        'confianza': 0.0,
        'status': 'fallback',
        'message': message,
        'categoryId': categoryId ?? 'general',
        'categoryName': categoryName ?? 'General',
        'daysAhead': daysAhead,
      },
      modelUsed: 'N/D',
      generatedAt: now,
    );
  }

  /// Determina si una respuesta es de fallback
  static bool isFallbackDashboard(AiDashboardResponse dashboard) {
    return dashboard.metrics.isNotEmpty &&
        dashboard.metrics.first.value == 'N/D';
  }

  /// Determina si un forecast es de fallback
  static bool isFallbackForecast(AiForecastResponse forecast) {
    return forecast.kpis['status'] == 'fallback';
  }

  /// Genera mensaje de error amigable según el código de estado HTTP
  static String getErrorMessage(int statusCode, {String? operation}) {
    final operationText = operation != null ? ' al $operation' : '';

    switch (statusCode) {
      case 401:
        return 'Sesión expirada$operationText. Por favor, inicia sesión nuevamente.';

      case 403:
        return 'No tienes permisos para acceder a esta función de IA.';

      case 404:
        return 'El servicio de IA no está disponible en este momento.';

      case 429:
        return 'Demasiadas solicitudes. Por favor, espera un momento antes de intentar nuevamente.';

      case 500:
        return 'Error interno del servidor de IA. Intenta nuevamente más tarde.';

      case 501:
        return 'Esta función de IA aún no está implementada en el servidor.';

      case 502:
      case 503:
      case 504:
        return 'El servidor de IA está temporalmente no disponible. Intenta más tarde.';

      default:
        if (statusCode >= 400 && statusCode < 500) {
          return 'Error al procesar la solicitud de IA. Verifica los datos e intenta nuevamente.';
        } else if (statusCode >= 500) {
          return 'Error del servidor de IA. Intenta nuevamente más tarde.';
        }
        return 'Error desconocido al conectar con el servicio de IA.';
    }
  }

  /// Genera mensaje de error según el tipo de excepción
  static String getExceptionMessage(dynamic error, {String? operation}) {
    final operationText = operation != null ? ' al $operation' : '';
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('timeout')) {
      return 'Tiempo de espera agotado$operationText. El servidor está tardando demasiado en responder.';
    }

    if (errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('socket')) {
      return 'Error de conexión$operationText. Verifica tu conexión a internet.';
    }

    if (errorString.contains('format') || errorString.contains('parse')) {
      return 'Error al procesar la respuesta del servidor de IA.';
    }

    return 'Error inesperado$operationText: ${error.toString()}';
  }
}
