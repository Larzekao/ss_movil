import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../data/ai_repository.dart';
import '../domain/ai_models.dart';

/// Estados posibles del módulo de IA
sealed class AiState {
  const AiState();
}

/// Estado inicial - sin datos cargados
class AiIdle extends AiState {
  const AiIdle();
}

/// Estado de carga - procesando request
class AiLoading extends AiState {
  const AiLoading();
}

/// Dashboard cargado exitosamente
class AiDashboardOk extends AiState {
  final AiDashboardResponse dashboard;
  const AiDashboardOk(this.dashboard);
}

/// Forecast generado exitosamente
class AiForecastOk extends AiState {
  final AiForecastResponse forecast;
  const AiForecastOk(this.forecast);
}

/// Modelo activo obtenido exitosamente
class AiModelOk extends AiState {
  final AiModelInfo model;
  const AiModelOk(this.model);
}

/// Error al procesar operación
class AiError extends AiState {
  final String message;
  const AiError(this.message);
}

/// Controlador de estado para módulo de Inteligencia Artificial
class AiController extends StateNotifier<AiState> {
  final AiRepository _repository;

  AiController(this._repository) : super(const AiIdle());

  /// Carga el dashboard de IA con métricas y estado actual
  ///
  /// [monthsBack] - Número de meses históricos a incluir (default: 6)
  /// [monthsForward] - Número de meses futuros en predicciones (default: 3)
  /// [forceRefresh] - Forzar recarga ignorando caché
  Future<void> loadDashboard({
    int monthsBack = 6,
    int monthsForward = 3,
    bool forceRefresh = false,
  }) async {
    state = const AiLoading();

    try {
      final dashboard = await _repository.getDashboard(
        monthsBack: monthsBack,
        monthsForward: monthsForward,
        forceRefresh: forceRefresh,
      );
      state = AiDashboardOk(dashboard);
    } on AiException catch (e) {
      state = AiError(e.message);
    } catch (e) {
      state = AiError('Error inesperado: $e');
    }
  }

  /// Genera predicción de ventas usando el modelo activo
  ///
  /// [nMonths] - Número de meses a predecir (debe ser > 0)
  /// [categoria] - Categoría específica a predecir (opcional)
  /// [forceRefresh] - Forzar recarga ignorando caché
  Future<void> getForecast({
    required int nMonths,
    String? categoria,
    bool forceRefresh = false,
  }) async {
    if (nMonths <= 0) {
      state = const AiError('El número de meses debe ser mayor a 0');
      return;
    }

    state = const AiLoading();

    try {
      final forecast = await _repository.forecast(
        nMonths: nMonths,
        categoria: categoria,
        forceRefresh: forceRefresh,
      );
      state = AiForecastOk(forecast);
    } on AiException catch (e) {
      state = AiError(e.message);
    } catch (e) {
      state = AiError('Error inesperado: $e');
    }
  }

  /// Obtiene información del modelo de IA actualmente activo
  Future<void> getActiveModel() async {
    state = const AiLoading();

    try {
      final model = await _repository.getActiveModel();
      state = AiModelOk(model);
    } on AiException catch (e) {
      state = AiError(e.message);
    } catch (e) {
      state = AiError('Error inesperado: $e');
    }
  }

  /// Inicia el entrenamiento de un nuevo modelo de IA
  /// Este proceso puede tardar varios minutos y se ejecuta en background
  ///
  /// Invalida el caché para forzar recarga después del entrenamiento
  Future<void> train() async {
    try {
      await _repository.trainModel();
      _repository.invalidateCache();
      // No cambiar estado - el entrenamiento se ejecuta en background
      // El usuario puede recargar el dashboard para ver el progreso
    } on AiException catch (e) {
      state = AiError(e.message);
    } catch (e) {
      state = AiError('Error inesperado: $e');
    }
  }

  /// Limpia el estado de error y vuelve a idle
  void clearError() {
    if (state is AiError) {
      state = const AiIdle();
    }
  }

  /// Reinicia el estado a idle
  void reset() {
    state = const AiIdle();
  }
}

/// Provider del controlador de IA
final aiControllerProvider = StateNotifierProvider<AiController, AiState>((
  ref,
) {
  final repository = ref.watch(aiRepositoryProvider);
  return AiController(repository);
});
