import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/storage/secure_storage.dart';
import 'package:ss_movil/features/accounts/application/state/auth_state.dart';
import 'package:ss_movil/features/accounts/domain/repositories/auth_repository.dart';

/// Controller para manejar el estado de autenticación
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SecureStorage _storage;

  AuthController(this._repository, this._storage)
    : super(const AuthState.initial());

  /// Verifica si hay tokens y carga el usuario
  Future<void> checkAuth() async {
    state = const AuthState.authenticating();

    final hasTokens = await _storage.hasTokens();

    if (!hasTokens) {
      state = const AuthState.unauthenticated();
      return;
    }

    // Intentar cargar usuario actual
    final result = await _repository.me();

    if (result.user != null) {
      state = AuthState.authenticated(result.user!);
    } else {
      // Tokens inválidos, limpiar
      await _repository.logout();
      state = const AuthState.unauthenticated();
    }
  }

  /// Login con email y contraseña
  Future<bool> login({required String email, required String password}) async {
    state = const AuthState.authenticating();

    final result = await _repository.login(email: email, password: password);

    if (result.user != null) {
      state = AuthState.authenticated(result.user!);
      return true;
    } else {
      state = AuthState.error(result.failure!.message);
      return false;
    }
  }

  /// Registro de nuevo usuario
  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    String? telefono,
  }) async {
    state = const AuthState.authenticating();

    final result = await _repository.register(
      email: email,
      password: password,
      nombre: nombre,
      apellido: apellido,
      telefono: telefono,
    );

    if (result.user != null) {
      // Después de registrar, hacer login
      return await login(email: email, password: password);
    } else {
      state = AuthState.error(result.failure!.message);
      return false;
    }
  }

  /// Recarga los datos del usuario actual
  Future<void> refreshUser() async {
    final result = await _repository.me();

    if (result.user != null) {
      state = AuthState.authenticated(result.user!);
    }
  }

  /// Logout
  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState.unauthenticated();
  }
}
