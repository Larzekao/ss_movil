import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/core/providers/app_providers.dart';
import 'package:ss_movil/shared/widgets/can.dart';
import 'package:ss_movil/shared/widgets/accounts_drawer.dart';

/// Página de listado de roles
class RolesListPage extends ConsumerStatefulWidget {
  const RolesListPage({super.key});

  @override
  ConsumerState<RolesListPage> createState() => _RolesListPageState();
}

class _RolesListPageState extends ConsumerState<RolesListPage> {
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
        title: const Text('Roles'),
        backgroundColor: Colors.deepPurple,
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
            AccountsDrawer(user: user, currentRoute: '/accounts/roles'),
        orElse: () => null,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar roles',
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

          // Lista
          Expanded(child: _buildRolesList()),
        ],
      ),
      floatingActionButton: Can(
        permissionCode: 'roles.crear',
        child: FloatingActionButton(
          onPressed: () {
            context.go('/accounts/roles/new');
          },
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildRolesList() {
    // TODO: Reemplazar con provider cuando esté listo
    final mockRoles = [
      {
        'id': '1',
        'nombre': 'Admin',
        'descripcion': 'Administrador del sistema',
        'esSistema': true,
      },
      {
        'id': '2',
        'nombre': 'Vendedor',
        'descripcion': 'Usuario vendedor',
        'esSistema': false,
      },
      {
        'id': '3',
        'nombre': 'Cliente',
        'descripcion': 'Cliente del sistema',
        'esSistema': false,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: mockRoles.length,
      itemBuilder: (context, index) {
        final role = mockRoles[index];
        final nombre = role['nombre'] as String;
        final descripcion = role['descripcion'] as String;
        final esSistema = role['esSistema'] as bool;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              child: Icon(Icons.badge, color: Colors.deepPurple.shade900),
            ),
            title: Row(
              children: [
                Text(nombre),
                if (esSistema) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text('Sistema'),
                    labelStyle: const TextStyle(fontSize: 10),
                    backgroundColor: Colors.orange.shade100,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
            subtitle: Text(descripcion),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/accounts/roles/${role['id']}/edit');
            },
          ),
        );
      },
    );
  }
}
