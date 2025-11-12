/// Endpoints del módulo de Inteligencia Artificial
///
/// Todos los endpoints están bajo /api/ai/
class AIEndpoints {
  // Base path (ya incluido en baseUrl del Dio)
  static const String _basePath = '/ai';

  /// GET /api/ai/dashboard/
  /// Obtiene el dashboard de IA con métricas y estado de modelos
  static const String aiDashboard = '$_basePath/dashboard/';

  /// POST /api/ai/predictions/sales-forecast/
  /// Genera predicciones de ventas usando el modelo activo
  static const String aiForecast = '$_basePath/predictions/sales-forecast/';

  /// POST /api/ai/train-model/
  /// Inicia el entrenamiento de un nuevo modelo de IA
  static const String aiTrain = '$_basePath/train-model/';

  /// GET /api/ai/active-model/
  /// Obtiene información del modelo de IA actualmente activo
  static const String aiActiveModel = '$_basePath/active-model/';

  /// GET /api/ai/models/
  /// Lista todos los modelos de IA disponibles
  static const String aiListModels = '$_basePath/models/';

  /// GET /api/ai/predictions/history/
  /// Obtiene el historial de predicciones realizadas
  static const String aiPredictionsHistory = '$_basePath/predictions/history/';
}
