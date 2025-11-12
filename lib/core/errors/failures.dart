import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Failures tipados para manejo de errores en arquitectura limpia
@freezed
class Failure with _$Failure {
  /// Error de red (timeout, no internet, etc)
  const factory Failure.network({required String message, int? statusCode}) =
      NetworkFailure;

  /// Error de autenticación (401, 403)
  const factory Failure.auth({required String message, int? statusCode}) =
      AuthFailure;

  /// Error del servidor (500, 502, etc)
  const factory Failure.server({required String message, int? statusCode}) =
      ServerFailure;

  /// Error de validación (400, 422)
  const factory Failure.validation({
    required String message,
    Map<String, List<String>>? errors,
  }) = ValidationFailure;

  /// Recurso no encontrado (404)
  const factory Failure.notFound({required String message, int? statusCode}) =
      NotFoundFailure;

  /// Error desconocido
  const factory Failure.unknown({required String message}) = UnknownFailure;
}
