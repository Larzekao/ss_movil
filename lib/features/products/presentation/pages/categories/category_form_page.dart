import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/features/products/domain/entities/category.dart';
import 'package:ss_movil/features/products/presentation/providers/categories_ui_provider.dart';
import 'package:ss_movil/shared/widgets/image_picker_widget.dart';

/// Página de formulario para crear/editar categoría
class CategoryFormPage extends ConsumerStatefulWidget {
  final String? categoryId; // null = crear, con valor = editar

  const CategoryFormPage({super.key, this.categoryId});

  @override
  ConsumerState<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends ConsumerState<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  bool _isLoading = false;
  bool _activa = true;
  String? _errorMessage;

  // Imagen seleccionada
  File? _selectedImage;
  String? _currentImageUrl;

  Category? _category;

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      // Usar WidgetsBinding para acceder al provider después del primer frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCategory();
      });
    }
  }

  void _loadCategory() {
    // Buscar la categoría en la lista cargada
    final categoriesState = ref.read(categoriesProvider);
    final category = categoriesState.categories.firstWhere(
      (cat) => cat.id == widget.categoryId,
    );

    setState(() {
      _category = category;
      _nombreController.text = category.nombre;
      _descripcionController.text = category.descripcion ?? '';
      _activa = category.activo;
      _currentImageUrl = category.imagen;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    bool success = false;

    if (_category == null) {
      // Crear nueva categoría
      success = await ref
          .read(categoriesProvider.notifier)
          .createCategory(
            nombre: _nombreController.text.trim(),
            descripcion: _descripcionController.text.trim().isEmpty
                ? null
                : _descripcionController.text.trim(),
            imagenPath: _selectedImage?.path,
            activo: _activa,
          );
    } else {
      // Actualizar categoría existente
      success = await ref
          .read(categoriesProvider.notifier)
          .updateCategory(
            id: _category!.id,
            nombre: _nombreController.text.trim(),
            descripcion: _descripcionController.text.trim().isEmpty
                ? null
                : _descripcionController.text.trim(),
            imagenPath: _selectedImage?.path,
            activo: _activa,
          );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        // Leer el error del estado si la operación falló
        if (!success) {
          final state = ref.read(categoriesProvider);
          _errorMessage = state.error;
        }
      });

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _category == null
                    ? 'Categoría creada exitosamente'
                    : 'Categoría actualizada exitosamente',
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/categories');
        }
      } else {
        final error = ref.read(categoriesProvider).error;
        setState(() {
          _errorMessage = error ?? 'Error al guardar categoría';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Categoría' : 'Nueva Categoría'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/categories'),
          tooltip: 'Volver',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mensaje de error
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                setState(() {
                                  _errorMessage = null;
                                });
                              },
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),

                    // Imagen
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Imagen',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Vista previa de imagen actual
                            if (_currentImageUrl != null &&
                                _selectedImage == null)
                              Column(
                                children: [
                                  Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _currentImageUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                              child: Icon(
                                                Icons.category,
                                                size: 64,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _currentImageUrl = null;
                                      });
                                    },
                                    icon: const Icon(Icons.delete, size: 18),
                                    label: const Text('Eliminar imagen'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            // Vista previa de imagen seleccionada
                            if (_selectedImage != null)
                              Column(
                                children: [
                                  Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedImage = null;
                                      });
                                    },
                                    icon: const Icon(Icons.delete, size: 18),
                                    label: const Text('Eliminar imagen'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            // Selector de imagen
                            if (_selectedImage == null &&
                                _currentImageUrl == null)
                              ImagePickerWidget(
                                label: 'Seleccionar imagen',
                                icon: Icons.add_photo_alternate,
                                onImageSelected: (file) {
                                  setState(() {
                                    _selectedImage = file;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Información básica
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información Básica',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Nombre
                            TextFormField(
                              controller: _nombreController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre *',
                                hintText: 'Ej: Camisetas, Pantalones, Zapatos',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El nombre es requerido';
                                }
                                if (value.trim().length < 3) {
                                  return 'El nombre debe tener al menos 3 caracteres';
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                            ),

                            const SizedBox(height: 16),

                            // Descripción
                            TextFormField(
                              controller: _descripcionController,
                              decoration: const InputDecoration(
                                labelText: 'Descripción',
                                hintText: 'Descripción de la categoría',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                              ),
                              maxLines: 3,
                              textCapitalization: TextCapitalization.sentences,
                            ),

                            const SizedBox(height: 16),

                            // Estado activo/inactivo
                            SwitchListTile(
                              title: const Text('Categoría activa'),
                              subtitle: Text(
                                _activa
                                    ? 'La categoría está visible y disponible'
                                    : 'La categoría está oculta',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              value: _activa,
                              onChanged: (value) {
                                setState(() {
                                  _activa = value;
                                });
                              },
                              activeThumbColor: Colors.teal,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(isEdit ? 'Actualizar' : 'Crear'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Nota informativa
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Las categorías se usan para organizar los productos. '
                              'Los campos marcados con * son obligatorios.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
