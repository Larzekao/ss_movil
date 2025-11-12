import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/exceptions/app_exceptions.dart';
import 'package:ss_movil/core/providers/dio_provider.dart';
import 'package:ss_movil/features/customers/application/usecases/get_preferences_usecase.dart';
import 'package:ss_movil/features/customers/application/usecases/update_preferences_usecase.dart';
import 'package:ss_movil/features/customers/domain/entities/preferencias.dart';
import 'package:ss_movil/features/customers/domain/repositories/customers_repository.dart';
import 'package:ss_movil/features/customers/infrastructure/datasources/customers_remote_datasource.dart';
import 'package:ss_movil/features/customers/infrastructure/repositories/customers_repository_impl.dart';
import 'package:ss_movil/features/customers/presentation/controllers/preferences_state.dart';

class PreferencesController extends StateNotifier<PreferencesState> {
  final GetPreferencesUseCase getPreferencesUseCase;
  final UpdatePreferencesUseCase updatePreferencesUseCase;

  Timer? _debounceTimer;
  static const int _debounceDurationMs = 400;

  PreferencesController({
    required this.getPreferencesUseCase,
    required this.updatePreferencesUseCase,
  }) : super(PreferencesState());

  /// Carga las preferencias del usuario
  Future<void> load() async {
    try {
      state = state.copyWith(loading: true, error: null);
      final prefs = await getPreferencesUseCase();
      state = state.copyWith(data: prefs, loading: false);
    } on AppException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Error desconocido: $e');
    }
  }

  /// Actualiza una o más preferencias con debounce (auto-save)
  void updateWithDebounce({
    bool? notificaciones,
    String? idioma,
    String? tallaFavorita,
  }) {
    // Cancelar timer anterior si existe
    _debounceTimer?.cancel();

    // Actualizar estado local inmediatamente (optimistic)
    if (state.data != null) {
      final updated = Preferencias(
        notificaciones: notificaciones ?? state.data!.notificaciones,
        idioma: idioma ?? state.data!.idioma,
        tallaFavorita: tallaFavorita ?? state.data!.tallaFavorita,
      );
      state = state.copyWith(data: updated, error: null, successMessage: null);
    }

    // Crear nuevo timer con debounce
    _debounceTimer = Timer(
      const Duration(milliseconds: _debounceDurationMs),
      () async {
        await _performUpdate(
          notificaciones: notificaciones,
          idioma: idioma,
          tallaFavorita: tallaFavorita,
        );
      },
    );
  }

  /// Realiza la actualización en el backend
  Future<void> _performUpdate({
    bool? notificaciones,
    String? idioma,
    String? tallaFavorita,
  }) async {
    try {
      final updated = await updatePreferencesUseCase(
        notificaciones: notificaciones,
        idioma: idioma,
        tallaFavorita: tallaFavorita,
      );
      state = state.copyWith(
        data: updated,
        error: null,
        successMessage: 'Preferencias guardadas',
      );

      // Limpiar mensaje de éxito después de 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (state.successMessage == 'Preferencias guardadas') {
          state = state.copyWith(successMessage: null);
        }
      });
    } on AppException catch (e) {
      state = state.copyWith(
        error: 'Error al guardar: ${e.message}',
        successMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Error desconocido: $e',
        successMessage: null,
      );
    }
  }

  /// Actualiza sin debounce (para actualizaciones inmediatas)
  Future<void> updateNow({
    bool? notificaciones,
    String? idioma,
    String? tallaFavorita,
  }) async {
    _debounceTimer?.cancel();
    await _performUpdate(
      notificaciones: notificaciones,
      idioma: idioma,
      tallaFavorita: tallaFavorita,
    );
  }

  /// Limpia el estado
  void clear() {
    _debounceTimer?.cancel();
    state = PreferencesState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Proveedor de Riverpod para GetPreferencesUseCase
final getPreferencesUseCaseProvider = Provider<GetPreferencesUseCase>((ref) {
  final repository = ref.watch(customersRepositoryProvider);
  return GetPreferencesUseCase(repository);
});

/// Proveedor de Riverpod para UpdatePreferencesUseCase
final updatePreferencesUseCaseProvider = Provider<UpdatePreferencesUseCase>((
  ref,
) {
  final repository = ref.watch(customersRepositoryProvider);
  return UpdatePreferencesUseCase(repository);
});

/// Proveedor de Riverpod para CustomersRepository (reutilizable)
final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final remoteDataSource = CustomersRemoteDatasource(dio);
  return CustomersRepositoryImpl(remoteDataSource);
});

/// Proveedor de Riverpod para PreferencesController
final preferencesControllerProvider =
    StateNotifierProvider<PreferencesController, PreferencesState>((ref) {
      final getPreferences = ref.watch(getPreferencesUseCaseProvider);
      final updatePreferences = ref.watch(updatePreferencesUseCaseProvider);

      return PreferencesController(
        getPreferencesUseCase: getPreferences,
        updatePreferencesUseCase: updatePreferences,
      );
    });
