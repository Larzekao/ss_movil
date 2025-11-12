import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/providers/dio_provider.dart';

/// Proveedor que indica si el usuario está autenticado
final authStateProvider = FutureProvider<bool>((ref) async {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return await tokenStorage.hasValidTokens();
});

/// Proveedor simplificado para verificación síncrona en routers
final isAuthenticatedProvider =
    StateNotifierProvider<IsAuthenticatedNotifier, bool>((ref) {
      return IsAuthenticatedNotifier(ref);
    });

class IsAuthenticatedNotifier extends StateNotifier<bool> {
  final Ref ref;

  IsAuthenticatedNotifier(this.ref) : super(false) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isAuth = await ref.watch(authStateProvider.future);
    state = isAuth;
  }

  Future<void> logout() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    await tokenStorage.clearTokens();
    state = false;
  }

  Future<void> login() async {
    state = true;
    await _checkAuth();
  }
}
