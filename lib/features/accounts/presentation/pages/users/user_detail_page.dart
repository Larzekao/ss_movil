import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/features/accounts/application/providers/users_providers.dart';

/// Página de detalle de usuario con acciones
class UserDetailPage extends ConsumerStatefulWidget {
  final String userId;

  const UserDetailPage({super.key, required this.userId});

  @override
  ConsumerState<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends ConsumerState<UserDetailPage> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userDetailProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Usuario'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/accounts/users');
          },
          tooltip: 'Volver',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.go('/accounts/users/${widget.userId}/edit');
            },
            tooltip: 'Editar',
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Error al cargar usuario',
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
                onPressed: () => ref.invalidate(userDetailProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (user) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar y nombre
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.indigo.shade100,
                      child: user.fotoPerfil != null
                          ? ClipOval(
                              child: Image.network(
                                user.fotoPerfil!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.indigo.shade900,
                                    ),
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.indigo.shade900,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.nombreCompleto,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Información Personal
              _buildInfoCard(context, 'Información Personal', [
                _InfoRow(label: 'Email', value: user.email),
                _InfoRow(label: 'Teléfono', value: user.telefono ?? 'N/A'),
                _InfoRow(
                  label: 'Código Empleado',
                  value: user.codigoEmpleado ?? 'N/A',
                ),
                _InfoRow(label: 'Rol', value: user.rol.nombre),
                _InfoRow(
                  label: 'Estado',
                  value: user.activo ? 'Activo' : 'Inactivo',
                ),
              ]),

              const SizedBox(height: 16),

              // Permisos
              if (user.rol.permisos.isNotEmpty)
                _buildPermissionsCard(context, user),

              const SizedBox(height: 16),

              // Acciones
              _buildActionsCard(context, user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsCard(BuildContext context, dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permisos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.rol.permisos
                  .map<Widget>(
                    (permission) => Chip(
                      label: Text(permission.nombre),
                      backgroundColor: Colors.indigo.shade100,
                      labelStyle: TextStyle(color: Colors.indigo.shade900),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Acciones',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Botón Editar
            ElevatedButton.icon(
              onPressed: () {
                context.go('/accounts/users/${widget.userId}/edit');
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar Usuario'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            // Botón Desactivar/Activar
            OutlinedButton.icon(
              onPressed: () {
                _showToggleActiveDialog(context, user, ref);
              },
              icon: Icon(user.activo ? Icons.block : Icons.check_circle),
              label: Text(
                user.activo ? 'Desactivar Usuario' : 'Activar Usuario',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                foregroundColor: user.activo ? Colors.orange : Colors.green,
              ),
            ),

            const SizedBox(height: 12),

            // Botón Eliminar
            OutlinedButton.icon(
              onPressed: () {
                _showDeleteDialog(context, user);
              },
              icon: const Icon(Icons.delete),
              label: const Text('Eliminar Usuario'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showToggleActiveDialog(
    BuildContext context,
    dynamic user,
    WidgetRef ref,
  ) {
    final isActivating = !user.activo;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isActivating ? 'Activar Usuario' : 'Desactivar Usuario'),
        content: Text(
          isActivating
              ? '¿Estás seguro de que deseas activar este usuario?'
              : '¿Estás seguro de que deseas desactivar este usuario?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final toggleUseCase = ref.read(toggleActiveUserUseCaseProvider);
                final result = await toggleUseCase(
                  userId: user.id,
                  isActive: isActivating,
                );

                result.fold(
                  (failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${failure.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  (updatedUser) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isActivating
                              ? 'Usuario activado'
                              : 'Usuario desactivado',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Refrescar datos
                    ref.invalidate(userDetailProvider(widget.userId));
                    ref.invalidate(usersListProvider);
                  },
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(isActivating ? 'Activar' : 'Desactivar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${user.nombreCompleto}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final deleteUseCase = ref.read(deleteUserUseCaseProvider);
                final result = await deleteUseCase(user.id);

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
                    context.go('/accounts/users');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Usuario eliminado correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Refrescar lista
                    ref.invalidate(usersListProvider);
                  },
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
