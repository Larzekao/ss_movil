import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:ss_movil/features/accounts/application/providers/users_providers.dart';
import 'package:ss_movil/features/accounts/application/providers/roles_providers.dart';

/// Página de formulario para crear/editar usuario
class UserFormPage extends ConsumerStatefulWidget {
  final String? userId;

  const UserFormPage({super.key, this.userId});

  bool get isEditMode => userId != null;

  @override
  ConsumerState<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends ConsumerState<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _codigoEmpleadoController = TextEditingController();
  final _fotoPerfildoController = TextEditingController();

  String? _selectedRoleId;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // ✅ Variables para imagen seleccionada
  File? _selectedImage;
  String? _imageBase64;

  @override
  void initState() {
    super.initState();
    // Los datos se cargarán en el build mediante el provider
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _codigoEmpleadoController.dispose();
    _fotoPerfildoController.dispose();
    super.dispose();
  }

  void _loadUserData(dynamic user) {
    // Cargar datos del usuario en los controladores
    _emailController.text = user.email;
    _nombreController.text = user.nombre;
    _apellidoController.text = user.apellido;
    _telefonoController.text = user.telefono ?? '';
    _codigoEmpleadoController.text = user.codigoEmpleado ?? '';
    _fotoPerfildoController.text = user.fotoPerfil ?? '';
    _selectedRoleId = user.rol.id; // ✅ Ahora es UUID
  }

  // ✅ Método para seleccionar imagen de galería
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // Convertir a base64
      final bytes = await _selectedImage!.readAsBytes();
      _imageBase64 = base64Encode(bytes);
    }
  }

  // ✅ Método para limpiar imagen seleccionada
  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _imageBase64 = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si es modo edición, cargar datos del usuario
    if (widget.isEditMode) {
      return _buildEditForm(context);
    }

    // Modo creación
    return _buildForm(context);
  }

  Widget _buildEditForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Usuario'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/accounts/users/${widget.userId}');
          },
          tooltip: 'Volver',
        ),
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final userAsync = ref.watch(userDetailProvider(widget.userId!));

          return userAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text('Error al cargar usuario'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(userDetailProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
            data: (user) {
              // Cargar datos del usuario cuando se reciben
              if (_nombreController.text.isEmpty) {
                _loadUserData(user);
              }
              return _buildFormContent();
            },
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Editar Usuario' : 'Nuevo Usuario'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/accounts/users');
          },
          tooltip: 'Volver',
        ),
      ),
      body: _buildFormContent(),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El email es requerido';
                }
                if (!value.contains('@')) {
                  return 'Email inválido';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Contraseña (solo en creación)
            if (!widget.isEditMode) ...[
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña *',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es requerida';
                  }
                  if (value.length < 8) {
                    return 'Mínimo 8 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña *',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirma la contraseña';
                  }
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
            ],

            // Nombre
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                prefixIcon: Icon(Icons.person),
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

            // Apellido
            TextFormField(
              controller: _apellidoController,
              decoration: const InputDecoration(
                labelText: 'Apellido *',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El apellido es requerido';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Teléfono
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                hintText: '+591 70000000',
              ),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            // Rol - Cargado desde provider
            Consumer(
              builder: (context, ref, child) {
                final rolesAsync = ref.watch(rolesListProvider);

                return rolesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Rol *',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    child: const Text('Error al cargar roles'),
                  ),
                  data: (roles) {
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedRoleId,
                      decoration: const InputDecoration(
                        labelText: 'Rol *',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                      items: roles.map((role) {
                        return DropdownMenuItem(
                          value: role.id,
                          child: Text(role.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRoleId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecciona un rol';
                        }
                        return null;
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // Código de empleado
            TextFormField(
              controller: _codigoEmpleadoController,
              decoration: const InputDecoration(
                labelText: 'Código de Empleado',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Foto de perfil - Seleccionar desde galería
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Foto de Perfil',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  // Preview de imagen
                  if (_selectedImage != null)
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else if (_fotoPerfildoController.text.isNotEmpty)
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(_fotoPerfildoController.text),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImageFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Seleccionar Foto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      if (_selectedImage != null) const SizedBox(width: 8),
                      if (_selectedImage != null)
                        ElevatedButton.icon(
                          onPressed: _clearImage,
                          icon: const Icon(Icons.clear),
                          label: const Text('Limpiar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botón guardar
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.isEditMode ? 'Guardar Cambios' : 'Crear Usuario',
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.isEditMode) {
        // EDITAR usuario
        final updateUseCase = ref.read(updateUserUseCaseProvider);
        final result = await updateUseCase(
          userId: widget.userId!,
          email: _emailController.text,
          nombre: _nombreController.text,
          apellido: _apellidoController.text,
          telefono: _telefonoController.text.isEmpty
              ? null
              : _telefonoController.text,
          roleId: _selectedRoleId,
          codigoEmpleado: _codigoEmpleadoController.text.isEmpty
              ? null
              : _codigoEmpleadoController.text,
          fotoPerfil:
              _imageBase64, // ✅ Enviar base64 si se seleccionó una imagen
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
          (user) {
            // Éxito
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Usuario actualizado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            ref.invalidate(userDetailProvider(widget.userId!));
            ref.invalidate(usersListProvider);
            context.go('/accounts/users/${widget.userId}');
          },
        );
      } else {
        // CREAR usuario
        final createUseCase = ref.read(createUserUseCaseProvider);
        final result = await createUseCase(
          email: _emailController.text,
          password: _passwordController.text,
          passwordConfirm: _confirmPasswordController.text,
          nombre: _nombreController.text,
          apellido: _apellidoController.text,
          telefono: _telefonoController.text.isEmpty
              ? null
              : _telefonoController.text,
          roleId: _selectedRoleId ?? '', // ✅ Ya es UUID string
          codigoEmpleado: _codigoEmpleadoController.text.isEmpty
              ? null
              : _codigoEmpleadoController.text,
          fotoPerfil:
              _imageBase64, // ✅ Enviar base64 si se seleccionó una imagen
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
          (user) {
            // Éxito
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Usuario creado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            ref.invalidate(usersListProvider);
            context.go('/accounts/users');
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
