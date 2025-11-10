import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/features/products/domain/entities/brand.dart';
import 'package:ss_movil/features/products/presentation/providers/brands_ui_provider.dart';
import 'package:ss_movil/shared/widgets/image_picker_widget.dart';

/// Página de formulario para crear/editar marca
class BrandFormPage extends ConsumerStatefulWidget {
  final String? brandId; // null = crear, con valor = editar

  const BrandFormPage({super.key, this.brandId});

  @override
  ConsumerState<BrandFormPage> createState() => _BrandFormPageState();
}

class _BrandFormPageState extends ConsumerState<BrandFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _sitioWebController = TextEditingController();

  bool _isLoading = false;
  bool _activa = true;
  String? _errorMessage;

  // Imagen seleccionada
  File? _selectedImage;
  String? _currentImageUrl;

  Brand? _brand;

  @override
  void initState() {
    super.initState();
    if (widget.brandId != null) {
      // Usar WidgetsBinding para acceder al provider después del primer frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadBrand();
      });
    }
  }

  void _loadBrand() {
    // Buscar la marca en la lista cargada
    final brandsState = ref.read(brandsProvider);
    final brand = brandsState.brands.firstWhere(
      (br) => br.id == widget.brandId,
    );

    setState(() {
      _brand = brand;
      _nombreController.text = brand.nombre;
      _descripcionController.text = brand.descripcion ?? '';
      _sitioWebController.text = brand.sitioWeb ?? '';
      _activa = brand.activo;
      _currentImageUrl = brand.logo;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _sitioWebController.dispose();
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

    if (_brand == null) {
      // Crear nueva marca
      success = await ref
          .read(brandsProvider.notifier)
          .createBrand(
            nombre: _nombreController.text.trim(),
            descripcion: _descripcionController.text.trim().isEmpty
                ? ''
                : _descripcionController.text.trim(),
            logo: _selectedImage?.path,
            sitioWeb: _sitioWebController.text.trim().isEmpty
                ? null
                : _sitioWebController.text.trim(),
            activo: _activa,
          );
    } else {
      // Actualizar marca existente
      success = await ref
          .read(brandsProvider.notifier)
          .updateBrand(
            id: _brand!.id,
            nombre: _nombreController.text.trim(),
            descripcion: _descripcionController.text.trim().isEmpty
                ? ''
                : _descripcionController.text.trim(),
            logo: _selectedImage?.path,
            sitioWeb: _sitioWebController.text.trim().isEmpty
                ? null
                : _sitioWebController.text.trim(),
            activo: _activa,
          );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        // Leer el error del estado si la operación falló
        if (!success) {
          final state = ref.read(brandsProvider);
          _errorMessage = state.error;
        }
      });

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _brand == null
                    ? 'Marca creada exitosamente'
                    : 'Marca actualizada exitosamente',
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/brands');
        }
      } else {
        final error = ref.read(brandsProvider).error;
        setState(() {
          _errorMessage = error ?? 'Error al guardar marca';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _brand != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Marca' : 'Nueva Marca'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/brands'),
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

                    // Sección de imagen/logo
                    if (isEdit && _currentImageUrl != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Logo Actual',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _currentImageUrl!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Selector de imagen
                    if (_selectedImage == null && _currentImageUrl == null)
                      ImagePickerWidget(
                        label: 'Seleccionar logo',
                        icon: Icons.add_photo_alternate,
                        onImageSelected: (file) {
                          setState(() {
                            _selectedImage = file;
                          });
                        },
                      ),

                    // Mostrar imagen seleccionada
                    if (_selectedImage != null)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Nombre
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la Marca *',
                        hintText: 'Ej: Nike, Adidas...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.branding_watermark),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        if (value.length < 2) {
                          return 'El nombre debe tener al menos 2 caracteres';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descripcionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        hintText: 'Describe la marca...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 4,
                    ),

                    const SizedBox(height: 16),

                    // Sitio Web
                    TextFormField(
                      controller: _sitioWebController,
                      decoration: InputDecoration(
                        labelText: 'Sitio Web',
                        hintText: 'https://www.ejemplo.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.public),
                      ),
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !_isValidUrl(value)) {
                          return 'Por favor ingresa una URL válida';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Estado Activo/Inactivo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Estado',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Switch(
                            value: _activa,
                            onChanged: (value) {
                              setState(() {
                                _activa = value;
                              });
                            },
                            activeThumbColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                          ),
                          Text(
                            _activa ? 'Activa' : 'Inactiva',
                            style: TextStyle(
                              color: _activa ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.go('/brands'),
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handleSubmit,
                            icon: Icon(
                              _isLoading
                                  ? Icons.hourglass_empty
                                  : Icons.check_circle,
                            ),
                            label: Text(
                              _isLoading
                                  ? 'Guardando...'
                                  : (isEdit ? 'Actualizar' : 'Crear'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
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

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
