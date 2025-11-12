/// Modelos del dominio de Inteligencia Artificial
library;

/// Respuesta del dashboard de IA
class AiDashboardResponse {
  final AiModelInfo? activeModel;
  final List<MetricItem> metrics;
  final List<PredictionHistoryItem> recentPredictions;

  const AiDashboardResponse({
    this.activeModel,
    required this.metrics,
    required this.recentPredictions,
  });

  factory AiDashboardResponse.fromJson(Map<String, dynamic> json) {
    return AiDashboardResponse(
      activeModel: json['active_model'] != null
          ? AiModelInfo.fromJson(json['active_model'] as Map<String, dynamic>)
          : null,
      metrics:
          (json['metrics'] as List<dynamic>?)
              ?.map((e) => MetricItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentPredictions:
          (json['recent_predictions'] as List<dynamic>?)
              ?.map(
                (e) =>
                    PredictionHistoryItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_model': activeModel?.toJson(),
      'metrics': metrics.map((e) => e.toJson()).toList(),
      'recent_predictions': recentPredictions.map((e) => e.toJson()).toList(),
    };
  }
}

/// Información de un modelo de IA
class AiModelInfo {
  final String id;
  final String name;
  final String status; // 'active', 'training', 'ready', 'failed'
  final double? accuracy;
  final DateTime? trainedAt;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  const AiModelInfo({
    required this.id,
    required this.name,
    required this.status,
    this.accuracy,
    this.trainedAt,
    this.createdAt,
    this.metadata,
  });

  factory AiModelInfo.fromJson(Map<String, dynamic> json) {
    return AiModelInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      accuracy: json['accuracy'] != null
          ? (json['accuracy'] as num).toDouble()
          : null,
      trainedAt: json['trained_at'] != null
          ? DateTime.parse(json['trained_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      if (accuracy != null) 'accuracy': accuracy,
      if (trainedAt != null) 'trained_at': trainedAt!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Métrica del dashboard
class MetricItem {
  final String label;
  final dynamic value;
  final String? unit;
  final String? trend; // 'up', 'down', 'stable'

  const MetricItem({
    required this.label,
    required this.value,
    this.unit,
    this.trend,
  });

  factory MetricItem.fromJson(Map<String, dynamic> json) {
    return MetricItem(
      label: json['label'] as String,
      value: json['value'],
      unit: json['unit'] as String?,
      trend: json['trend'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      if (unit != null) 'unit': unit,
      if (trend != null) 'trend': trend,
    };
  }
}

/// Item del historial de predicciones
class PredictionHistoryItem {
  final String id;
  final DateTime createdAt;
  final String type; // 'sales_forecast', etc.
  final Map<String, dynamic>? params;
  final Map<String, dynamic>? result;

  const PredictionHistoryItem({
    required this.id,
    required this.createdAt,
    required this.type,
    this.params,
    this.result,
  });

  factory PredictionHistoryItem.fromJson(Map<String, dynamic> json) {
    return PredictionHistoryItem(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      type: json['type'] as String,
      params: json['params'] as Map<String, dynamic>?,
      result: json['result'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'type': type,
      if (params != null) 'params': params,
      if (result != null) 'result': result,
    };
  }
}

/// Request para predicción de ventas
class AiForecastRequest {
  final int nMonths;
  final String? categoria;

  const AiForecastRequest({required this.nMonths, this.categoria});

  Map<String, dynamic> toJson() {
    return {'n_months': nMonths, if (categoria != null) 'categoria': categoria};
  }
}

/// Respuesta de predicción de ventas
class AiForecastResponse {
  final List<ForecastPoint> forecast;
  final Map<String, dynamic> kpis;
  final String? modelUsed;
  final DateTime generatedAt;

  const AiForecastResponse({
    required this.forecast,
    required this.kpis,
    this.modelUsed,
    required this.generatedAt,
  });

  factory AiForecastResponse.fromJson(Map<String, dynamic> json) {
    return AiForecastResponse(
      forecast:
          (json['forecast'] as List<dynamic>?)
              ?.map((e) => ForecastPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      kpis: json['kpis'] as Map<String, dynamic>? ?? {},
      modelUsed: json['model_used'] as String?,
      generatedAt: json['generated_at'] != null
          ? DateTime.parse(json['generated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'forecast': forecast.map((e) => e.toJson()).toList(),
      'kpis': kpis,
      if (modelUsed != null) 'model_used': modelUsed,
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}

/// Punto de datos en la serie temporal de predicción
class ForecastPoint {
  final DateTime date;
  final double value;
  final double? lowerBound;
  final double? upperBound;
  final bool isHistorical;

  const ForecastPoint({
    required this.date,
    required this.value,
    this.lowerBound,
    this.upperBound,
    required this.isHistorical,
  });

  factory ForecastPoint.fromJson(Map<String, dynamic> json) {
    return ForecastPoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      lowerBound: json['lower_bound'] != null
          ? (json['lower_bound'] as num).toDouble()
          : null,
      upperBound: json['upper_bound'] != null
          ? (json['upper_bound'] as num).toDouble()
          : null,
      isHistorical: json['is_historical'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      if (lowerBound != null) 'lower_bound': lowerBound,
      if (upperBound != null) 'upper_bound': upperBound,
      'is_historical': isHistorical,
    };
  }
}

/// Excepciones personalizadas del módulo IA
class AiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const AiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() =>
      'AiException: $message ${statusCode != null ? '(HTTP $statusCode)' : ''}';
}

class AiUnauthorizedException extends AiException {
  const AiUnauthorizedException([super.message = 'No autorizado'])
    : super(statusCode: 401);
}

class AiBadRequestException extends AiException {
  const AiBadRequestException([super.message = 'Solicitud inválida'])
    : super(statusCode: 400);
}

class AiServerException extends AiException {
  const AiServerException([super.message = 'Error del servidor'])
    : super(statusCode: 500);
}

class AiNetworkException extends AiException {
  const AiNetworkException([super.message = 'Error de red']);
}
