import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/user.dart';

/// Repositorio abstracto para autenticación (Domain)
/// Las implementaciones estarán en Infrastructure
abstract class AuthRepository {
  /// Login con email y contraseña
  /// Returns: User si éxito, Failure si error
  Future<({User? user, Failure? failure})> login({
    required String email,
    required String password,
  });

  /// Registro de nuevo usuario (rol Cliente por defecto)
  Future<({User? user, Failure? failure})> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    String? telefono,
  });

  /// Obtener usuario actual (requiere autenticación)
  Future<({User? user, Failure? failure})> me();

  /// Refresh del access token usando refresh token
  Future<({String? accessToken, Failure? failure})> refresh({
    required String refreshToken,
  });

  /// Logout (limpia tokens locales, no hace petición al backend)
  Future<void> logout();
}
