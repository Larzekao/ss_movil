import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/core/providers/app_providers.dart';
import 'package:ss_movil/features/accounts/application/state/auth_state.dart';

/// Página de Splash con verificación de autenticación
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      // Agregar delay mínimo para mostrar splash
      await Future.delayed(const Duration(seconds: 1));

      // Verificar autenticación con timeout
      await ref
          .read(authControllerProvider.notifier)
          .checkAuth()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              // Si timeout, ir a login
              if (mounted) {
                context.go('/login');
              }
            },
          );
    } catch (e) {
      // Si hay error, ir a login
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en el estado de autenticación
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      next.when(
        initial: () {},
        unauthenticated: () {
          if (mounted) context.go('/login');
        },
        authenticating: () {},
        authenticated: (_) {
          if (mounted) context.go('/home');
        },
        error: (_) {
          if (mounted) context.go('/login');
        },
      );
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'SS Movil',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
