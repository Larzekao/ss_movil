import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/core/providers/app_providers.dart';
import 'package:ss_movil/features/accounts/application/providers/roles_providers.dart';
import 'package:ss_movil/shared/widgets/can.dart';
import 'package:ss_movil/shared/widgets/accounts_drawer.dart';

/// Página de listado de roles
class RolesListPage extends ConsumerStatefulWidget {
  const RolesListPage({super.key});

  @override
  ConsumerState<RolesListPage> createState() => _RolesListPageState();
}

class _RolesListPageState extends ConsumerState<RolesListPage> {
  Future<void> _handleDeleteRole(String roleId, String roleName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar rol'),
        content: Text('¿Está seguro de que desea eliminar el rol "$roleName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final deleteUseCase = ref.read(deleteRoleUseCaseProvider);
    final result = await deleteUseCase(roleId);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rol eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(rolesListProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final searchTerm = ref.watch(rolesSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Roles'),
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
              onChanged: (value) {
                ref.read(rolesSearchProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Buscar roles...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: searchTerm.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(rolesSearchProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Lista de roles
          Expanded(child: _buildRolesList()),
        ],
      ),
      floatingActionButton: Can(
        permissionCode: 'roles.crear',
        child: FloatingActionButton.extended(
          onPressed: () {
            context.go('/accounts/roles/new');
          },
          backgroundColor: Colors.deepPurple,
          icon: const Icon(Icons.add),
          label: const Text('Nuevo Rol'),
        ),
      ),
    );
  }

  Widget _buildRolesList() {
    final rolesAsync = ref.watch(rolesListProvider);

    return rolesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error al cargar roles',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(rolesListProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (roles) {
        if (roles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.badge_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay roles disponibles',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: roles.length,
          itemBuilder: (context, index) {
            final role = roles[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade100,
                  child: Icon(Icons.badge, color: Colors.deepPurple.shade900),
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(role.nombre)),
                    if (role.esRolSistema)
                      Chip(
                        label: const Text('Sistema'),
                        labelStyle: const TextStyle(fontSize: 10),
                        backgroundColor: Colors.orange.shade100,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      role.descripcion ?? 'Sin descripción',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${role.permisos.length} permisos',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: _buildTrailingMenu(ref, role),
                onTap: () {
                  context.go('/accounts/roles/${role.id}');
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTrailingMenu(WidgetRef ref, dynamic role) {
    final userAsync = ref.watch(authControllerProvider);

    return userAsync.maybeWhen(
      authenticated: (user) {
        final canEdit = user.tienePermiso('roles.actualizar');
        final canDelete = user.tienePermiso('roles.eliminar');

        return PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              context.go('/accounts/roles/${role.id}/edit');
            } else if (value == 'delete') {
              _handleDeleteRole(role.id, role.nombre);
            } else if (value == 'view') {
              context.go('/accounts/roles/${role.id}');
            }
          },
          itemBuilder: (BuildContext context) {
            final items = <PopupMenuEntry<String>>[];

            items.add(
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 18),
                    SizedBox(width: 8),
                    Text('Ver'),
                  ],
                ),
              ),
            );

            if (canEdit) {
              items.add(
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
              );
            }

            if (!role.esRolSistema && canDelete) {
              items.add(
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar'),
                    ],
                  ),
                ),
              );
            }

            return items;
          },
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
