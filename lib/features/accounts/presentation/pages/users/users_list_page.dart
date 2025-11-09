import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/core/providers/app_providers.dart';
import 'package:ss_movil/features/accounts/application/providers/users_providers.dart';
import 'package:ss_movil/shared/widgets/can.dart';
import 'package:ss_movil/shared/widgets/accounts_drawer.dart';

/// Página de lista de usuarios con búsqueda, filtros y paginación
class UsersListPage extends ConsumerStatefulWidget {
  const UsersListPage({super.key});

  @override
  ConsumerState<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends ConsumerState<UsersListPage> {
  final _searchController = TextEditingController();
  bool? _filterActive;

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
        title: const Text('Gestión de Usuarios'),
        backgroundColor: Colors.indigo,
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
            AccountsDrawer(user: user, currentRoute: '/accounts/users'),
        orElse: () => null,
      ),
      body: Column(
        children: [
          // ✅ Barra de búsqueda y filtros integrados
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Campo de búsqueda con icono de filtro integrado
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o email...',
                    prefixIcon: const Icon(Icons.search),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),

                const SizedBox(height: 12),

                // Filtro de Estado en una fila
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.tune, color: Colors.indigo),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<bool?>(
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: const Text('Filtrar por Estado'),
                            value: _filterActive,
                            items: [
                              DropdownMenuItem(
                                value: null,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.done_all,
                                      color: Colors.grey.shade600,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Todos'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: true,
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Activos'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: false,
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Inactivos'),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _filterActive = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de usuarios
          Expanded(child: _buildUsersList()),
        ],
      ),

      // Botón flotante para crear usuario
      floatingActionButton: Can(
        permissionCode: 'usuarios.crear',
        child: FloatingActionButton.extended(
          onPressed: () {
            context.go('/accounts/users/new');
          },
          icon: const Icon(Icons.person_add),
          label: const Text('Nuevo Usuario'),
          backgroundColor: Colors.indigo,
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return Consumer(
      builder: (context, ref, _) {
        // Observamos el provider con los parámetros actuales
        final usersAsyncValue = ref.watch(
          usersListProvider(
            UsersListParams(
              search: _searchController.text.isEmpty
                  ? null
                  : _searchController.text,
              isActive: _filterActive,
            ),
          ),
        );

        return usersAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar usuarios',
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
                  onPressed: () => ref.invalidate(usersListProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
          data: (pagedUsers) {
            if (pagedUsers.results.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se encontraron usuarios',
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
              itemCount: pagedUsers.results.length,
              itemBuilder: (context, index) {
                final user = pagedUsers.results[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: user.fotoPerfil != null
                          ? ClipOval(
                              child: Image.network(
                                user.fotoPerfil!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Text(
                                      user.nombre[0].toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.indigo.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              ),
                            )
                          : Text(
                              user.nombre[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.indigo.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    title: Text(user.nombreCompleto),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(user.activo ? 'Activo' : 'Inactivo'),
                          backgroundColor: user.activo
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          labelStyle: TextStyle(
                            color: user.activo
                                ? Colors.green.shade900
                                : Colors.red.shade900,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {
                      context.go('/accounts/users/${user.id}');
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
