import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/features/accounts/application/providers/roles_providers.dart';
import 'package:ss_movil/features/accounts/domain/entities/permission.dart';
import 'package:ss_movil/features/accounts/presentation/providers/permissions_providers.dart';

/// Página de formulario para crear/editar roles
class RoleFormPage extends ConsumerStatefulWidget {
  final String? roleId;
  final bool isEdit;

  const RoleFormPage({super.key, this.roleId, this.isEdit = false});

  @override
  ConsumerState<RoleFormPage> createState() => _RoleFormPageState();
}

class _RoleFormPageState extends ConsumerState<RoleFormPage> {
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  final Set<String> _selectedPermissionIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _descripcionController = TextEditingController();

    if (widget.isEdit && widget.roleId != null) {
      _loadRoleData();
    }
  }

  Future<void> _loadRoleData() async {
    final getRoleUseCase = ref.read(getRoleUseCaseProvider);
    final result = await getRoleUseCase(widget.roleId!);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (role) {
        _nombreController.text = role.nombre;
        _descripcionController.text = role.descripcion ?? '';
        setState(() {
          _selectedPermissionIds.addAll(role.permisos.map((p) => p.id));
        });
      },
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre del rol es requerido'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isEdit && widget.roleId != null) {
        // Actualizar rol existente
        final updateUseCase = ref.read(updateRoleUseCaseProvider);
        final descripcionTrimmed = _descripcionController.text.trim();
        final result = await updateUseCase(
          roleId: widget.roleId!,
          nombre: _nombreController.text.trim(),
          descripcion: descripcionTrimmed.isEmpty ? null : descripcionTrimmed,
          permisosIds: _selectedPermissionIds.toList(),
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
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rol actualizado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            ref.invalidate(rolesListProvider);
            ref.invalidate(roleDetailProvider);
            context.go('/accounts/roles');
          },
        );
      } else {
        // Crear nuevo rol
        final createUseCase = ref.read(createRoleUseCaseProvider);
        final descripcionTrimmed = _descripcionController.text.trim();
        final result = await createUseCase(
          nombre: _nombreController.text.trim(),
          descripcion: descripcionTrimmed.isEmpty ? null : descripcionTrimmed,
          permisosIds: _selectedPermissionIds.toList(),
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
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rol creado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            ref.invalidate(rolesListProvider);
            context.go('/accounts/roles');
          },
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Editar Rol' : 'Crear Nuevo Rol'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo Nombre
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del Rol',
                hintText: 'Ej: Supervisor',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.badge),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Campo Descripción
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                hintText: 'Descripción del rol',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),

            // Sección de Permisos
            Text('Permisos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildPermissionsSection(),
            const SizedBox(height: 32),

            // Botones de Acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => context.pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleSubmit,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(widget.isEdit ? Icons.check : Icons.add),
                    label: Text(widget.isEdit ? 'Actualizar' : 'Crear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsSection() {
    final permissionsAsync = ref.watch(permissionsListProvider);

    return permissionsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Error al cargar permisos: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
      data: (permissions) {
        if (permissions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No hay permisos disponibles',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }

        // Agrupar permisos por módulo (parte antes del punto)
        final groupedPermissions = <String, List<Permission>>{};
        for (final permission in permissions) {
          final module = permission.codigo.split('.').first;
          if (!groupedPermissions.containsKey(module)) {
            groupedPermissions[module] = [];
          }
          groupedPermissions[module]!.add(permission);
        }

        return Column(
          children: groupedPermissions.entries.map((entry) {
            final moduleName = entry.key;
            final modulePermissions = entry.value;

            return _buildModulePermissionsGroup(moduleName, modulePermissions);
          }).toList(),
        );
      },
    );
  }

  Widget _buildModulePermissionsGroup(
    String moduleName,
    List<Permission> permissions,
  ) {
    final selectedCount = permissions
        .where((p) => _selectedPermissionIds.contains(p.id))
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            moduleName.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '$selectedCount de ${permissions.length} seleccionados',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: permissions.map((permission) {
                  return CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(permission.nombre),
                    subtitle: Text(
                      permission.codigo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    value: _selectedPermissionIds.contains(permission.id),
                    onChanged: _isLoading
                        ? null
                        : (bool? isChecked) {
                            setState(() {
                              if (isChecked == true) {
                                _selectedPermissionIds.add(permission.id);
                              } else {
                                _selectedPermissionIds.remove(permission.id);
                              }
                            });
                          },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
