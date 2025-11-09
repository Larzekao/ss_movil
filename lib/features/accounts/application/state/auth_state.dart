import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ss_movil/features/accounts/domain/entities/user.dart';

part 'auth_state.freezed.dart';

/// Estados de autenticación
@freezed
class AuthState with _$AuthState {
  /// Estado inicial (aún no se ha verificado autenticación)
  const factory AuthState.initial() = _Initial;

  /// Sin autenticar (no hay tokens o son inválidos)
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// Autenticando (loading)
  const factory AuthState.authenticating() = _Authenticating;

  /// Autenticado con usuario cargado
  const factory AuthState.authenticated(User user) = _Authenticated;

  /// Error en autenticación
  const factory AuthState.error(String message) = _Error;
}
