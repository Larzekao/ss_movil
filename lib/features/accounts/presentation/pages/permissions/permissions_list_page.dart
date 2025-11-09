import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/core/providers/app_providers.dart';
import 'package:ss_movil/shared/widgets/accounts_drawer.dart';

/// Página de listado de permisos (solo lectura)
class PermissionsListPage extends ConsumerStatefulWidget {
  const PermissionsListPage({super.key});

  @override
  ConsumerState<PermissionsListPage> createState() =>
      _PermissionsListPageState();
}

class _PermissionsListPageState extends ConsumerState<PermissionsListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

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
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar permisos',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Lista agrupada por módulo
          Expanded(child: _buildPermissionsList()),
        ],
      ),
    );
  }

  Widget _buildPermissionsList() {
    // TODO: Reemplazar con provider cuando esté listo
    final mockPermissions = {
      'Usuarios': [
        {
          'codigo': 'usuarios.listar',
          'nombre': 'Listar usuarios',
          'descripcion': 'Ver lista de usuarios',
        },
        {
          'codigo': 'usuarios.crear',
          'nombre': 'Crear usuario',
          'descripcion': 'Crear nuevos usuarios',
        },
        {
          'codigo': 'usuarios.editar',
          'nombre': 'Editar usuario',
          'descripcion': 'Modificar usuarios existentes',
        },
        {
          'codigo': 'usuarios.eliminar',
          'nombre': 'Eliminar usuario',
          'descripcion': 'Eliminar usuarios',
        },
      ],
      'Roles': [
        {
          'codigo': 'roles.listar',
          'nombre': 'Listar roles',
          'descripcion': 'Ver lista de roles',
        },
        {
          'codigo': 'roles.crear',
          'nombre': 'Crear rol',
          'descripcion': 'Crear nuevos roles',
        },
        {
          'codigo': 'roles.editar',
          'nombre': 'Editar rol',
          'descripcion': 'Modificar roles existentes',
        },
        {
          'codigo': 'roles.eliminar',
          'nombre': 'Eliminar rol',
          'descripcion': 'Eliminar roles',
        },
      ],
      'Permisos': [
        {
          'codigo': 'permisos.listar',
          'nombre': 'Listar permisos',
          'descripcion': 'Ver lista de permisos del sistema',
        },
      ],
      'Productos': [
        {
          'codigo': 'productos.listar',
          'nombre': 'Listar productos',
          'descripcion': 'Ver catálogo de productos',
        },
        {
          'codigo': 'productos.crear',
          'nombre': 'Crear producto',
          'descripcion': 'Agregar nuevos productos',
        },
        {
          'codigo': 'productos.editar',
          'nombre': 'Editar producto',
          'descripcion': 'Modificar productos existentes',
        },
        {
          'codigo': 'productos.eliminar',
          'nombre': 'Eliminar producto',
          'descripcion': 'Eliminar productos',
        },
      ],
      'Clientes': [
        {
          'codigo': 'clientes.listar',
          'nombre': 'Listar clientes',
          'descripcion': 'Ver lista de clientes',
        },
        {
          'codigo': 'clientes.crear',
          'nombre': 'Crear cliente',
          'descripcion': 'Registrar nuevos clientes',
        },
        {
          'codigo': 'clientes.editar',
          'nombre': 'Editar cliente',
          'descripcion': 'Modificar información de clientes',
        },
        {
          'codigo': 'clientes.eliminar',
          'nombre': 'Eliminar cliente',
          'descripcion': 'Eliminar clientes',
        },
      ],
      'Pedidos': [
        {
          'codigo': 'pedidos.listar',
          'nombre': 'Listar pedidos',
          'descripcion': 'Ver lista de pedidos',
        },
        {
          'codigo': 'pedidos.crear',
          'nombre': 'Crear pedido',
          'descripcion': 'Crear nuevos pedidos',
        },
        {
          'codigo': 'pedidos.editar',
          'nombre': 'Editar pedido',
          'descripcion': 'Modificar pedidos',
        },
        {
          'codigo': 'pedidos.eliminar',
          'nombre': 'Eliminar pedido',
          'descripcion': 'Cancelar/eliminar pedidos',
        },
      ],
    };

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: mockPermissions.entries.map((entry) {
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
              final codigo = permiso['codigo'] as String;
              final nombre = permiso['nombre'] as String;
              final descripcion = permiso['descripcion'] as String;

              return ListTile(
                dense: true,
                title: Text(nombre),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(descripcion, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      codigo,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
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
    switch (modulo) {
      case 'Usuarios':
        return Icons.people;
      case 'Roles':
        return Icons.badge;
      case 'Permisos':
        return Icons.security;
      case 'Productos':
        return Icons.inventory_2;
      case 'Clientes':
        return Icons.person;
      case 'Pedidos':
        return Icons.shopping_cart;
      default:
        return Icons.folder;
    }
  }
}
