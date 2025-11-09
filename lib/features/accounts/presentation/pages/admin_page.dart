import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/providers/app_providers.dart';
import 'package:ss_movil/shared/widgets/can.dart';

/// Página de administración protegida por RBAC
///
/// Esta página solo es accesible para usuarios con el permiso 'admin.acceso'
/// Se usa como ejemplo de ProtectedRoute en la navegación.
class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: authState.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        unauthenticated: () => const Center(child: Text('No autenticado')),
        authenticating: () => const Center(child: CircularProgressIndicator()),
        error: (message) => Center(child: Text('Error: $message')),
        authenticated: (user) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del usuario
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido, Administrador',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Usuario: ${user.nombre} ${user.apellido}'),
                      Text('Email: ${user.email}'),
                      Text('Rol: ${user.rol.nombre}'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sección de gestión de usuarios
              Text(
                'Gestión de Usuarios',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Botones protegidos por permisos específicos
              Can(
                permissionCode: 'usuarios.crear',
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_add, color: Colors.green),
                    title: const Text('Crear Usuario'),
                    subtitle: const Text('Añadir nuevos usuarios al sistema'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showSnackBar(context, 'Navegar a Crear Usuario');
                    },
                  ),
                ),
              ),

              Can(
                permissionCode: 'usuarios.listar',
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.list, color: Colors.blue),
                    title: const Text('Ver Usuarios'),
                    subtitle: const Text('Lista de todos los usuarios'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showSnackBar(context, 'Navegar a Lista de Usuarios');
                    },
                  ),
                ),
              ),

              Can(
                permissionCode: 'usuarios.eliminar',
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Eliminar Usuarios'),
                    subtitle: const Text('Gestionar eliminación de usuarios'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showSnackBar(context, 'Navegar a Eliminar Usuario');
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sección de gestión de productos
              Text(
                'Gestión de Productos',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Can(
                permissionCode: 'productos.crear',
                child: Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.green,
                    ),
                    title: const Text('Crear Producto'),
                    subtitle: const Text('Añadir nuevos productos'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showSnackBar(context, 'Navegar a Crear Producto');
                    },
                  ),
                ),
              ),

              Can(
                permissionCode: 'productos.editar',
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.edit, color: Colors.orange),
                    title: const Text('Editar Productos'),
                    subtitle: const Text('Modificar productos existentes'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showSnackBar(context, 'Navegar a Editar Producto');
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sección de reportes (requiere múltiples permisos)
              Text(
                'Reportes y Estadísticas',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              CanMultiple(
                permissionCodes: ['reportes.ventas', 'reportes.inventario'],
                requireAll: false, // Cualquiera de los dos permisos
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.assessment, color: Colors.purple),
                    title: const Text('Ver Reportes'),
                    subtitle: const Text(
                      'Acceso a reportes de ventas e inventario',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showSnackBar(context, 'Navegar a Reportes');
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sección solo para super admin
              CanByRole(
                roleName: 'Superadministrador',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuración del Sistema',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: Colors.red.shade50,
                      child: ListTile(
                        leading: const Icon(Icons.settings, color: Colors.red),
                        title: const Text('Configuración Avanzada'),
                        subtitle: const Text('Solo Superadministrador'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _showSnackBar(context, 'Navegar a Configuración');
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Información de permisos del usuario
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Tus Permisos',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tienes ${user.rol.permisos.length} permisos asignados:',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.rol.permisos
                            .take(10) // Mostrar solo los primeros 10
                            .map(
                              (permiso) => Chip(
                                label: Text(
                                  permiso.codigo,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.blue.shade100,
                              ),
                            )
                            .toList(),
                      ),
                      if (user.rol.permisos.length > 10)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'y ${user.rol.permisos.length - 10} más...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
