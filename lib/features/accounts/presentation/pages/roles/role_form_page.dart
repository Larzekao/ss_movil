import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Página de formulario para crear/editar rol
class RoleFormPage extends StatefulWidget {
  final String? roleId;

  const RoleFormPage({super.key, this.roleId});

  bool get isEditMode => roleId != null;

  @override
  State<RoleFormPage> createState() => _RoleFormPageState();
}

class _RoleFormPageState extends State<RoleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  bool _isLoading = false;
  bool _esSistema = false;
  final Map<String, bool> _selectedPermissions = {};

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      _loadRole();
    }
  }

  void _loadRole() {
    // TODO: Cargar datos del rol
    setState(() {
      _nombreController.text = 'Rol ${widget.roleId}';
      _descripcionController.text = 'Descripción del rol';
      _esSistema = widget.roleId == '1';
      // Mock permissions
      _selectedPermissions['usuarios.listar'] = true;
      _selectedPermissions['usuarios.crear'] = true;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Editar Rol' : 'Nuevo Rol'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/accounts/roles');
          },
          tooltip: 'Volver',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Advertencia rol de sistema
              if (_esSistema)
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Este es un rol de sistema y no puede ser eliminado',
                            style: TextStyle(color: Colors.orange.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_esSistema) const SizedBox(height: 16),

              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Permisos
              Text(
                'Permisos',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              _buildPermissionsSection(),

              const SizedBox(height: 32),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.isEditMode ? 'Guardar' : 'Crear'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsSection() {
    // TODO: Cargar permisos desde provider
    final mockPermissions = {
      'Usuarios': [
        {'codigo': 'usuarios.listar', 'nombre': 'Listar usuarios'},
        {'codigo': 'usuarios.crear', 'nombre': 'Crear usuario'},
        {'codigo': 'usuarios.editar', 'nombre': 'Editar usuario'},
        {'codigo': 'usuarios.eliminar', 'nombre': 'Eliminar usuario'},
      ],
      'Roles': [
        {'codigo': 'roles.listar', 'nombre': 'Listar roles'},
        {'codigo': 'roles.crear', 'nombre': 'Crear rol'},
        {'codigo': 'roles.editar', 'nombre': 'Editar rol'},
        {'codigo': 'roles.eliminar', 'nombre': 'Eliminar rol'},
      ],
      'Productos': [
        {'codigo': 'productos.listar', 'nombre': 'Listar productos'},
        {'codigo': 'productos.crear', 'nombre': 'Crear producto'},
        {'codigo': 'productos.editar', 'nombre': 'Editar producto'},
        {'codigo': 'productos.eliminar', 'nombre': 'Eliminar producto'},
      ],
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: mockPermissions.entries.map((entry) {
            final modulo = entry.key;
            final permisos = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  modulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...permisos.map((permiso) {
                  final codigo = permiso['codigo'] as String;
                  final nombre = permiso['nombre'] as String;

                  return CheckboxListTile(
                    title: Text(nombre),
                    subtitle: Text(
                      codigo,
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _selectedPermissions[codigo] ?? false,
                    onChanged: (value) {
                      setState(() {
                        _selectedPermissions[codigo] = value ?? false;
                      });
                    },
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }),
                const Divider(height: 24),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedPerms = _selectedPermissions.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedPerms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un permiso'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implementar con provider
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        context.go('/accounts/roles');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditMode
                  ? 'Rol actualizado exitosamente'
                  : 'Rol creado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
