import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/providers/app_providers.dart';

/// Widget que protege rutas completas basado en permisos RBAC
///
/// Si el usuario no tiene el permiso requerido, muestra un widget de acceso denegado
/// o redirige automáticamente.
///
/// Ejemplo de uso en una ruta:
/// ```dart
/// GoRoute(
///   path: '/admin',
///   builder: (context, state) => ProtectedRoute(
///     requiredPermission: 'admin.acceso',
///     child: AdminPage(),
///   ),
/// )
/// ```
class ProtectedRoute extends ConsumerWidget {
  /// Widget a mostrar si el usuario tiene el permiso
  final Widget child;

  /// Código del permiso requerido (opcional)
  /// Si no se proporciona, solo verifica que esté autenticado
  final String? requiredPermission;

  /// Nombre del rol requerido (alternativa a requiredPermission)
  final String? requiredRole;

  /// Widget a mostrar si no tiene acceso
  /// Por defecto muestra una página de acceso denegado
  final Widget? accessDeniedWidget;

  /// Si true, redirige a onAccessDenied en lugar de mostrar accessDeniedWidget
  final bool redirectOnDenied;

  /// Callback cuando se deniega el acceso (usado con redirectOnDenied)
  final VoidCallback? onAccessDenied;

  const ProtectedRoute({
    super.key,
    required this.child,
    this.requiredPermission,
    this.requiredRole,
    this.accessDeniedWidget,
    this.redirectOnDenied = false,
    this.onAccessDenied,
  }) : assert(
         requiredPermission != null || requiredRole != null,
         'Debe proporcionar requiredPermission o requiredRole',
       );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      initial: () => const _LoadingScreen(),
      unauthenticated: () => _buildAccessDenied(context, 'No autenticado'),
      authenticating: () => const _LoadingScreen(),
      error: (message) => _buildAccessDenied(context, message),
      authenticated: (user) {
        bool hasAccess = true;

        // Verificar permiso si se proporcionó
        if (requiredPermission != null) {
          hasAccess = user.tienePermiso(requiredPermission!);
        }

        // Verificar rol si se proporcionó (y no se verificó permiso)
        if (requiredRole != null && requiredPermission == null) {
          hasAccess = user.tieneRol(requiredRole!);
        }

        if (hasAccess) {
          return child;
        }

        // Acceso denegado
        if (redirectOnDenied && onAccessDenied != null) {
          // Ejecutar callback en el siguiente frame para evitar problemas con el build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onAccessDenied!();
          });
          return const _LoadingScreen();
        }

        return _buildAccessDenied(
          context,
          'No tienes permiso para acceder a esta sección',
        );
      },
    );
  }

  Widget _buildAccessDenied(BuildContext context, String message) {
    if (accessDeniedWidget != null) {
      return accessDeniedWidget!;
    }

    return _AccessDeniedPage(message: message);
  }
}

/// Pantalla de carga mientras se verifica autenticación
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Página por defecto de acceso denegado
class _AccessDeniedPage extends StatelessWidget {
  final String message;

  const _AccessDeniedPage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acceso Denegado'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Acceso Denegado',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Retroceder o ir al home
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Variante que protege basándose en múltiples permisos
class ProtectedRouteMultiple extends ConsumerWidget {
  final Widget child;
  final List<String> requiredPermissions;
  final bool requireAll;
  final Widget? accessDeniedWidget;

  const ProtectedRouteMultiple({
    super.key,
    required this.child,
    required this.requiredPermissions,
    this.requireAll = true,
    this.accessDeniedWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      initial: () => const _LoadingScreen(),
      unauthenticated: () => _buildAccessDenied(context),
      authenticating: () => const _LoadingScreen(),
      error: (_) => _buildAccessDenied(context),
      authenticated: (user) {
        bool hasAccess;

        if (requireAll) {
          hasAccess = requiredPermissions.every(
            (code) => user.tienePermiso(code),
          );
        } else {
          hasAccess = requiredPermissions.any(
            (code) => user.tienePermiso(code),
          );
        }

        if (hasAccess) {
          return child;
        }

        return _buildAccessDenied(context);
      },
    );
  }

  Widget _buildAccessDenied(BuildContext context) {
    if (accessDeniedWidget != null) {
      return accessDeniedWidget!;
    }

    return const _AccessDeniedPage(
      message: 'No tienes los permisos necesarios para acceder a esta sección',
    );
  }
}
