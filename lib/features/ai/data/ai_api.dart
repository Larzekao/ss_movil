import 'package:dio/dio.dart';
import '../ai_endpoints.dart';
import '../domain/ai_models.dart';

/// Cliente API para endpoints de Inteligencia Artificial
class AiApi {
  final Dio _dio;

  const AiApi(this._dio);

  /// GET /api/ai/dashboard/
  /// Obtiene el dashboard de IA con métricas y estado
  ///
  /// [monthsBack] - Número de meses históricos a incluir en métricas
  /// [monthsForward] - Número de meses futuros en predicciones previas
  Future<AiDashboardResponse> getDashboard({
    int? monthsBack,
    int? monthsForward,
  }) async {
    final queryParams = <String, dynamic>{};
    if (monthsBack != null) queryParams['months_back'] = monthsBack;
    if (monthsForward != null) queryParams['months_forward'] = monthsForward;

    final response = await _dio.get(
      AIEndpoints.aiDashboard,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return AiDashboardResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /api/ai/predictions/sales-forecast/
  /// Genera predicción de ventas usando el modelo activo
  ///
  /// [nMonths] - Número de meses a predecir (requerido)
  /// [categoria] - Categoría específica a predecir (opcional)
  Future<AiForecastResponse> forecast({
    required int nMonths,
    String? categoria,
  }) async {
    final request = AiForecastRequest(nMonths: nMonths, categoria: categoria);

    final response = await _dio.post(
      AIEndpoints.aiForecast,
      data: request.toJson(),
    );

    return AiForecastResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/ai/active-model/
  /// Obtiene información del modelo de IA actualmente activo
  Future<AiModelInfo> getActiveModel() async {
    final response = await _dio.get(AIEndpoints.aiActiveModel);
    return AiModelInfo.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /api/ai/train-model/
  /// Inicia el entrenamiento de un nuevo modelo de IA
  /// Este proceso puede tardar varios minutos
  Future<void> trainModel() async {
    await _dio.post(AIEndpoints.aiTrain);
  }

  /// GET /api/ai/models/
  /// Lista todos los modelos de IA disponibles
  Future<List<AiModelInfo>> listModels() async {
    final response = await _dio.get(AIEndpoints.aiListModels);
    final data = response.data as List<dynamic>;
    return data
        .map((json) => AiModelInfo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/ai/predictions/history/
  /// Obtiene el historial de predicciones realizadas
  ///
  /// [limit] - Número máximo de predicciones a retornar
  Future<List<PredictionHistoryItem>> getPredictionsHistory({
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;

    final response = await _dio.get(
      AIEndpoints.aiPredictionsHistory,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final data = response.data as List<dynamic>;
    return data
        .map(
          (json) =>
              PredictionHistoryItem.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}
