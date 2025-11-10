import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/features/products/application/providers/products_providers.dart';
import 'package:ss_movil/features/products/domain/repositories/products_repository.dart';
import 'package:ss_movil/features/products/domain/entities/category.dart';
import 'package:ss_movil/features/products/domain/entities/brand.dart';
import 'package:ss_movil/features/products/domain/entities/size.dart';
import 'package:ss_movil/features/products/presentation/widgets/category_picker.dart';
import 'package:ss_movil/features/products/presentation/widgets/brand_picker.dart';
import 'package:ss_movil/features/products/presentation/widgets/size_picker.dart';
import 'package:ss_movil/shared/widgets/image_picker_widget.dart';
import 'package:ss_movil/core/errors/failures.dart';

/// Página de formulario para crear/editar producto
class ProductFormPage extends ConsumerStatefulWidget {
  final String? slug; // null = crear, con valor = editar

  const ProductFormPage({super.key, this.slug});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _codigoController = TextEditingController();
  final _materialController = TextEditingController();
  final _colorController = TextEditingController();
  final _imagenUrlController = TextEditingController();

  bool _isLoading = false;
  bool _activa = true;
  String? _errorMessage;
  Map<String, List<String>>? _validationErrors;

  // Para el modo edición
  String? _productId;

  // Categoría, marca y tallas seleccionadas
  Category? _selectedCategory;
  Brand? _selectedBrand;
  List<Size> _selectedSizes = [];

  // Imágenes seleccionadas del picker
  File? _selectedImage;
  List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.slug != null) {
      _loadProductForEdit();
    }
  }

  Future<void> _loadProductForEdit() async {
    setState(() {
      _isLoading = true;
    });

    final getProductUseCase = ref.read(getProductUseCaseProvider);
    final result = await getProductUseCase(widget.slug!);

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = _getFailureMessage(failure);
        });
      },
      (product) {
        setState(() {
          _isLoading = false;
          _productId = product.id;
          _nombreController.text = product.nombre;
          _descripcionController.text = product.descripcion;
          _precioController.text = product.precio.cantidad.toString();
          _codigoController.text = product.codigo;
          _materialController.text = product.material ?? '';
          _colorController.text = product.color ?? '';
          _activa = product.activo;
          _selectedCategory = product.categoria;
          _selectedBrand = product.marca;
          _selectedSizes = product.tallas;
          if (product.imagenes.isNotEmpty) {
            _imagenUrlController.text = product.imagenes.first.url;
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _codigoController.dispose();
    _materialController.dispose();
    _colorController.dispose();
    _imagenUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.slug != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Producto' : 'Crear Producto'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
              tooltip: 'Eliminar',
            ),
        ],
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
                    // Mensajes de error general
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
                          ],
                        ),
                      ),

                    // Errores de validación por campo
                    if (_validationErrors != null &&
                        _validationErrors!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange),
                                SizedBox(width: 8),
                                Text(
                                  'Errores de validación:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ..._validationErrors!.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  '• ${entry.key}: ${entry.value.join(", ")}',
                                  style: const TextStyle(color: Colors.orange),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                    // Nombre
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Producto *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.checkroom),
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
                        labelText: 'Descripción *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La descripción es requerida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Precio
                    TextFormField(
                      controller: _precioController,
                      decoration: const InputDecoration(
                        labelText: 'Precio *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El precio es requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingrese un precio válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Código
                    TextFormField(
                      controller: _codigoController,
                      decoration: const InputDecoration(
                        labelText: 'Código',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Material
                    TextFormField(
                      controller: _materialController,
                      decoration: const InputDecoration(
                        labelText: 'Material',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.texture),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Color
                    TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(
                        labelText: 'Color',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.palette),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selector de Categoría
                    InkWell(
                      onTap: () async {
                        final category = await showCategoryPicker(
                          context,
                          initialCategory: _selectedCategory,
                        );
                        if (category != null) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Categoría *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedCategory?.nombre ??
                                    'Seleccione una categoría',
                                style: TextStyle(
                                  color: _selectedCategory != null
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selector de Marca
                    InkWell(
                      onTap: () async {
                        final brand = await showBrandPicker(
                          context,
                          initialBrand: _selectedBrand,
                        );
                        if (brand != null) {
                          setState(() {
                            _selectedBrand = brand;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Marca *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedBrand?.nombre ??
                                    'Seleccione una marca',
                                style: TextStyle(
                                  color: _selectedBrand != null
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selector de Tallas
                    InkWell(
                      onTap: () async {
                        final sizes = await showSizePicker(
                          context,
                          initialSizes: _selectedSizes,
                        );
                        if (sizes != null) {
                          setState(() {
                            _selectedSizes = sizes;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tallas *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.straighten),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _selectedSizes.isEmpty
                                  ? const Text(
                                      'Seleccione tallas',
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  : Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: _selectedSizes.map((size) {
                                        return Chip(
                                          label: Text(
                                            size.nombre,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          backgroundColor:
                                              Colors.deepPurple.shade50,
                                          deleteIcon: const Icon(
                                            Icons.close,
                                            size: 16,
                                          ),
                                          onDeleted: () {
                                            setState(() {
                                              _selectedSizes.removeWhere(
                                                (s) => s.id == size.id,
                                              );
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selector de imagen
                    ImagePickerWidget(
                      onImageSelected: (imageFile) {
                        setState(() {
                          _selectedImage = imageFile;
                          _selectedImages = [imageFile];
                          _imagenUrlController.clear();
                        });
                      },
                      onMultipleImagesSelected: (imageFiles) {
                        setState(() {
                          _selectedImage = imageFiles.isNotEmpty
                              ? imageFiles.first
                              : null;
                          _selectedImages = imageFiles;
                          _imagenUrlController.clear();
                        });
                      },
                      allowMultiple: true,
                      label: 'Foto del Producto',
                      icon: Icons.camera_alt,
                    ),
                    const SizedBox(height: 16),

                    // Switch de activo
                    SwitchListTile(
                      title: const Text('Producto Activo'),
                      subtitle: const Text(
                        'Los productos inactivos no se muestran al público',
                      ),
                      value: _activa,
                      onChanged: (value) {
                        setState(() {
                          _activa = value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Nota sobre campos faltantes
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Stock por talla y carga de imágenes se configurarán en una versión futura',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botón de guardar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isEdit ? 'Actualizar Producto' : 'Crear Producto',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveProduct() async {
    // Limpiar errores anteriores
    setState(() {
      _errorMessage = null;
      _validationErrors = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final precio = double.parse(_precioController.text);

    if (widget.slug != null && _productId != null) {
      // Actualizar producto existente
      await _updateProduct(precio);
    } else {
      // Crear nuevo producto
      await _createProduct(precio);
    }
  }

  Future<void> _createProduct(double precio) async {
    final createUseCase = ref.read(createProductUseCaseProvider);

    // Validar que categoría y marca estén seleccionadas
    if (_selectedCategory == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Debe seleccionar una categoría';
      });
      return;
    }

    if (_selectedBrand == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Debe seleccionar una marca';
      });
      return;
    }

    if (_selectedSizes.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Debe seleccionar al menos una talla';
      });
      return;
    }

    final request = CreateProductRequest(
      nombre: _nombreController.text,
      descripcion: _descripcionController.text,
      precio: precio,
      stock: 0, // Stock inicial
      codigo: _codigoController.text.isEmpty
          ? 'PROD-${DateTime.now().millisecondsSinceEpoch}'
          : _codigoController.text,
      categoryId: _selectedCategory!.id,
      brandId: _selectedBrand!.id,
      sizeIds: _selectedSizes.map((size) => size.id).toList(),
      material: _materialController.text.isEmpty
          ? null
          : _materialController.text,
      color: _colorController.text.isEmpty ? null : _colorController.text,
      imagenPath: _selectedImage?.path, // Pasar la ruta de la imagen
      // Nota: activo se manejará en el backend; CreateProductRequest no lo incluye
    );

    final result = await createUseCase(request);

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = _getFailureMessage(failure);
          if (failure is ValidationFailure) {
            _validationErrors = failure.errors;
          }
        });
      },
      (product) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/products');
        }
      },
    );
  }

  Future<void> _updateProduct(double precio) async {
    final updateUseCase = ref.read(updateProductUseCaseProvider);

    // Validar que categoría y marca estén seleccionadas
    if (_selectedCategory == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Debe seleccionar una categoría';
      });
      return;
    }

    if (_selectedBrand == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Debe seleccionar una marca';
      });
      return;
    }

    if (_selectedSizes.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Debe seleccionar al menos una talla';
      });
      return;
    }

    final request = UpdateProductRequest(
      nombre: _nombreController.text,
      descripcion: _descripcionController.text,
      precio: precio,
      codigo: _codigoController.text.isEmpty ? null : _codigoController.text,
      categoryId: _selectedCategory!.id,
      brandId: _selectedBrand!.id,
      sizeIds: _selectedSizes.map((size) => size.id).toList(),
      material: _materialController.text.isEmpty
          ? null
          : _materialController.text,
      color: _colorController.text.isEmpty ? null : _colorController.text,
      activo: _activa,
    );

    final result = await updateUseCase(_productId!, request);

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = _getFailureMessage(failure);
          if (failure is ValidationFailure) {
            _validationErrors = failure.errors;
          }
        });
      },
      (product) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/products');
        }
      },
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Está seguro de que desea eliminar este producto?\n\nEsta acción realizará una eliminación suave (soft delete).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && _productId != null) {
      await _deleteProduct();
    }
  }

  Future<void> _deleteProduct() async {
    setState(() {
      _isLoading = true;
    });

    final deleteUseCase = ref.read(deleteProductUseCaseProvider);
    final result = await deleteUseCase(_productId!);

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: ${_getFailureMessage(failure)}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (_) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/products');
        }
      },
    );
  }

  String _getFailureMessage(Failure failure) {
    return failure.when(
      validation: (message, errors) => message,
      auth: (message, statusCode) => message,
      server: (message, statusCode) => message,
      network: (message, statusCode) => message,
      unknown: (message) => message,
    );
  }
}
