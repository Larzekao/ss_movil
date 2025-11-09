import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/core/providers/app_providers.dart';
import 'package:ss_movil/features/accounts/application/providers/permissions_providers.dart';
import 'package:ss_movil/shared/widgets/accounts_drawer.dart';

/// Página de listado de permisos (solo lectura)
class PermissionsListPage extends ConsumerStatefulWidget {
  const PermissionsListPage({super.key});

  @override
  ConsumerState<PermissionsListPage> createState() =>
      _PermissionsListPageState();
}

class _PermissionsListPageState extends ConsumerState<PermissionsListPage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final searchTerm = ref.watch(permissionsSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permisos del Sistema'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
          tooltip: 'Volver al inicio',
        ),
      ),
      drawer: authState.maybeWhen(
        authenticated: (user) =>
            AccountsDrawer(user: user, currentRoute: '/accounts/permissions'),
        orElse: () => null,
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.teal.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Los permisos son de solo lectura. Asígnalos a los roles para controlar el acceso.',
                    style: TextStyle(color: Colors.teal.shade900),
                  ),
                ),
              ],
            ),
          ),

          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                ref.read(permissionsSearchProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                labelText: 'Buscar permisos',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: searchTerm.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(permissionsSearchProvider.notifier).state =
                              '';
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Lista agrupada por módulo
          Expanded(
            child: ref
                .watch(permissionsGroupedProvider)
                .when(
                  data: (grouped) => _buildPermissionsList(grouped),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: $error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(permissionsGroupedProvider);
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsList(Map<String, List> grouped) {
    if (grouped.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron permisos',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: grouped.entries.map((entry) {
        final modulo = entry.key;
        final permisos = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: Icon(
                _getModuleIcon(modulo),
                color: Colors.teal.shade900,
                size: 20,
              ),
            ),
            title: Text(
              modulo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${permisos.length} permisos'),
            children: permisos.map((permiso) {
              final nombre = '${permiso.modulo}.${permiso.codigo}';

              return ListTile(
                dense: true,
                title: Text(nombre),
                leading: Icon(
                  Icons.security,
                  size: 16,
                  color: Colors.grey[600],
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  IconData _getModuleIcon(String modulo) {
    switch (modulo.toLowerCase()) {
      case 'usuarios':
        return Icons.people;
      case 'roles':
        return Icons.badge;
      case 'permisos':
        return Icons.security;
      case 'productos':
        return Icons.inventory_2;
      case 'clientes':
        return Icons.person;
      case 'pedidos':
        return Icons.shopping_cart;
      case 'categorias':
        return Icons.category;
      case 'marcas':
        return Icons.label;
      case 'ventas':
        return Icons.trending_up;
      case 'envios':
        return Icons.local_shipping;
      case 'reportes':
        return Icons.assessment;
      case 'descuentos':
        return Icons.discount;
      case 'dashboard':
        return Icons.dashboard;
      default:
        return Icons.folder;
    }
  }
}
