import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/core/providers/app_providers.dart';
import 'package:ss_movil/shared/widgets/can.dart';
import 'package:ss_movil/shared/widgets/accounts_drawer.dart';

/// Página principal (Home) con logout funcional y ejemplos de RBAC
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.maybeWhen(
      authenticated: (user) => Scaffold(
        appBar: AppBar(
          title: const Text('Inicio'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              tooltip: 'Cerrar sesión',
            ),
          ],
        ),
        drawer: AccountsDrawer(user: user, currentRoute: '/home'),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.check_circle, size: 100, color: Colors.green),
                const SizedBox(height: 24),
                Text(
                  '¡Bienvenido, ${user.nombre}!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Información del usuario
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Rol', value: user.rol.nombre),
                        const Divider(),
                        _InfoRow(
                          label: 'Permisos',
                          value: '${user.rol.permisos.length}',
                        ),
                        if (user.telefono != null) ...[
                          const Divider(),
                          _InfoRow(label: 'Teléfono', value: user.telefono!),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Sección: Acciones disponibles según permisos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Acciones Disponibles',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Botón protegido: Crear Producto
                      Can(
                        permissionCode: 'productos.crear',
                        fallback: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.lock, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                'Crear Producto (Sin permiso)',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Navegando a Crear Producto...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Crear Producto'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Botón protegido: Editar Productos
                      Can(
                        permissionCode: 'productos.editar',
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Navegando a Editar Productos...',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar Productos'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Botón protegido: Ver Reportes
                      CanMultiple(
                        permissionCodes: [
                          'reportes.ventas',
                          'reportes.inventario',
                        ],
                        requireAll: false, // Cualquiera de los dos
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Navegando a Reportes...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.assessment),
                          label: const Text('Ver Reportes'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Botón protegido: Panel de Admin
                      Can(
                        permissionCode: 'admin.acceso',
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.go('/admin');
                          },
                          icon: const Icon(Icons.admin_panel_settings),
                          label: const Text('Panel de Administración'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Botón protegido: Gestión de Roles
                      Can(
                        permissionCode: 'roles.leer',
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.go('/accounts/roles');
                          },
                          icon: const Icon(Icons.badge),
                          label: const Text('Gestión de Roles'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Mensaje especial para superadmin
                      CanByRole(
                        roleName: 'Superadministrador',
                        child: Card(
                          color: Colors.red.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: const [
                                Icon(Icons.star, color: Colors.red),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Eres Superadministrador - Tienes acceso total al sistema',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      orElse: () => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Ir a Login'),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
