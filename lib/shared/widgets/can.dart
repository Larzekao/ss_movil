import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/providers/app_providers.dart';

/// Widget para control de permisos basado en RBAC
///
/// Oculta o muestra el widget hijo según si el usuario tiene el permiso especificado.
/// Se integra con AuthController para verificar permisos en tiempo real.
///
/// Ejemplo de uso:
/// ```dart
/// Can(
///   permissionCode: 'productos.crear',
///   child: ElevatedButton(
///     onPressed: () => crearProducto(),
///     child: Text('Crear Producto'),
///   ),
/// )
/// ```
///
/// Si el usuario no tiene el permiso 'productos.crear', el botón no se mostrará.
class Can extends ConsumerWidget {
  /// Código del permiso a verificar (ej: 'productos.crear', 'usuarios.eliminar')
  final String permissionCode;

  /// Widget a mostrar si el usuario tiene el permiso
  final Widget child;

  /// Widget alternativo a mostrar si el usuario NO tiene el permiso
  /// Si es null, no se muestra nada
  final Widget? fallback;

  /// Si true, muestra el child cuando NO tiene el permiso (invierte la lógica)
  final bool negate;

  const Can({
    super.key,
    required this.permissionCode,
    required this.child,
    this.fallback,
    this.negate = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    // Si no está autenticado, no mostrar nada
    return authState.when(
      initial: () => fallback ?? const SizedBox.shrink(),
      unauthenticated: () => fallback ?? const SizedBox.shrink(),
      authenticating: () => fallback ?? const SizedBox.shrink(),
      error: (_) => fallback ?? const SizedBox.shrink(),
      authenticated: (user) {
        final hasPermission = user.tienePermiso(permissionCode);

        // Aplicar lógica de negación si está activa
        final shouldShow = negate ? !hasPermission : hasPermission;

        if (shouldShow) {
          return child;
        }

        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Variante que verifica si el usuario tiene un rol específico
///
/// Ejemplo de uso:
/// ```dart
/// CanByRole(
///   roleName: 'Administrador',
///   child: Text('Panel de Admin'),
/// )
/// ```
class CanByRole extends ConsumerWidget {
  /// Nombre del rol a verificar
  final String roleName;

  /// Widget a mostrar si el usuario tiene el rol
  final Widget child;

  /// Widget alternativo si no tiene el rol
  final Widget? fallback;

  const CanByRole({
    super.key,
    required this.roleName,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      initial: () => fallback ?? const SizedBox.shrink(),
      unauthenticated: () => fallback ?? const SizedBox.shrink(),
      authenticating: () => fallback ?? const SizedBox.shrink(),
      error: (_) => fallback ?? const SizedBox.shrink(),
      authenticated: (user) {
        final hasRole = user.tieneRol(roleName);

        if (hasRole) {
          return child;
        }

        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Verifica múltiples permisos con lógica AND u OR
///
/// Ejemplo con AND (todos los permisos requeridos):
/// ```dart
/// CanMultiple(
///   permissionCodes: ['productos.crear', 'productos.editar'],
///   requireAll: true,
///   child: Text('Gestionar productos'),
/// )
/// ```
///
/// Ejemplo con OR (al menos un permiso):
/// ```dart
/// CanMultiple(
///   permissionCodes: ['admin.acceso', 'superadmin.acceso'],
///   requireAll: false,
///   child: Text('Panel administrativo'),
/// )
/// ```
class CanMultiple extends ConsumerWidget {
  /// Lista de códigos de permisos a verificar
  final List<String> permissionCodes;

  /// Si true, requiere TODOS los permisos (AND)
  /// Si false, requiere AL MENOS uno (OR)
  final bool requireAll;

  /// Widget a mostrar si cumple los requisitos
  final Widget child;

  /// Widget alternativo si no cumple
  final Widget? fallback;

  const CanMultiple({
    super.key,
    required this.permissionCodes,
    this.requireAll = true,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      initial: () => fallback ?? const SizedBox.shrink(),
      unauthenticated: () => fallback ?? const SizedBox.shrink(),
      authenticating: () => fallback ?? const SizedBox.shrink(),
      error: (_) => fallback ?? const SizedBox.shrink(),
      authenticated: (user) {
        bool hasPermissions;
        if (requireAll) {
          // AND: todos los permisos son necesarios
          hasPermissions = permissionCodes.every(
            (code) => user.tienePermiso(code),
          );
        } else {
          // OR: al menos un permiso es suficiente
          hasPermissions = permissionCodes.any(
            (code) => user.tienePermiso(code),
          );
        }

        if (hasPermissions) {
          return child;
        }

        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}
