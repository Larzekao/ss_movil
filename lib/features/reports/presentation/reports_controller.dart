import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../data/reports_repository.dart';
import '../domain/preview_response.dart';
import '../domain/template_item.dart';

/// Reports state variants
sealed class ReportsState {}

/// Initial state
class ReportsIdle extends ReportsState {}

/// Loading state
class ReportsLoading extends ReportsState {}

/// Preview loaded successfully
class ReportsPreviewOk extends ReportsState {
  final PreviewResponse preview;
  ReportsPreviewOk(this.preview);
}

/// Error state
class ReportsError extends ReportsState {
  final String message;
  ReportsError(this.message);
}

/// StateNotifier for Reports
class ReportsController extends StateNotifier<ReportsState> {
  final ReportsRepository _repository;

  ReportsController(this._repository) : super(ReportsIdle());

  /// Preview report data from natural language prompt
  ///
  /// Sets state to Loading, then PreviewOk or Error
  Future<void> doPreview(String prompt) async {
    state = ReportsLoading();

    try {
      final preview = await _repository.preview(prompt);
      state = ReportsPreviewOk(preview);
    } catch (e) {
      state = ReportsError(_extractErrorMessage(e));
    }
  }

  /// Generate report file from natural language prompt
  ///
  /// Returns (bytes, filename, mimeType) on success, null on error
  /// Sets state to Error if fails
  Future<(Uint8List, String, String)?> doGenerate(
    String prompt, {
    String? format,
  }) async {
    try {
      return await _repository.generate(prompt, format: format);
    } catch (e) {
      state = ReportsError(_extractErrorMessage(e));
      return null;
    }
  }

  /// Get available report templates
  ///
  /// Returns list of templates or empty list on error
  Future<List<TemplateItem>> getTemplates() async {
    try {
      return await _repository.templates();
    } catch (e) {
      state = ReportsError(_extractErrorMessage(e));
      return [];
    }
  }

  /// Generate predefined report
  ///
  /// Returns (bytes, filename, mimeType) on success, null on error
  /// Sets state to Error if fails
  Future<(Uint8List, String, String)?> generatePredefined({
    required String reportType,
    Map<String, dynamic>? params,
    String? format,
  }) async {
    try {
      return await _repository.predefined(
        reportType: reportType,
        params: params,
        format: format,
      );
    } catch (e) {
      state = ReportsError(_extractErrorMessage(e));
      return null;
    }
  }

  /// Reset state to idle
  void reset() {
    state = ReportsIdle();
  }

  /// Extract user-friendly error message from exception
  String _extractErrorMessage(dynamic error) {
    // Handle DioException with specific status codes
    if (error is DioException) {
      final response = error.response;

      if (response != null) {
        switch (response.statusCode) {
          case 401:
            return 'Sesión expirada. Por favor vuelve a iniciar sesión.';
          case 400:
            return 'Revisa el prompt o parámetros del reporte.';
          case 403:
            return 'No tienes permisos para generar este reporte.';
          case 404:
            return 'Endpoint de reportes no encontrado.';
          case 500:
          case 502:
          case 503:
          case 504:
            return 'Error del servidor. Intenta de nuevo.';
          default:
            return 'Error: ${response.statusMessage ?? "Desconocido"}';
        }
      }

      // Handle connection errors
      if (error.type == DioExceptionType.connectionTimeout) {
        return 'Tiempo de conexión agotado. Verifica tu conexión.';
      }
      if (error.type == DioExceptionType.receiveTimeout) {
        return 'El servidor tardó demasiado en responder.';
      }
      if (error.type == DioExceptionType.sendTimeout) {
        return 'Tiempo de envío agotado. Intenta de nuevo.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Error de conexión. Verifica tu red.';
      }
      if (error.type == DioExceptionType.cancel) {
        return 'Operación cancelada.';
      }

      return 'Error de red: ${error.message ?? "Desconocido"}';
    }

    // Handle TimeoutException
    if (error is TimeoutException) {
      return 'Tiempo de espera agotado. El reporte es muy grande o el servidor está ocupado.';
    }

    // Handle SocketException
    if (error is SocketException) {
      return 'Error de conexión. Verifica tu red.';
    }

    // Generic Exception
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }

    return 'Error inesperado: ${error.toString()}';
  }
}

/// Provider for ReportsController
final reportsControllerProvider =
    StateNotifierProvider<ReportsController, ReportsState>((ref) {
      final repository = ref.read(reportsRepositoryProvider);
      return ReportsController(repository);
    });
