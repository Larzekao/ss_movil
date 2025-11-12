import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/features/products/application/providers/products_providers.dart';
import 'package:ss_movil/features/products/domain/entities/product.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/shared/widgets/can.dart';

/// Página de detalle de producto
class ProductDetailPage extends ConsumerStatefulWidget {
  final String slug;

  const ProductDetailPage({super.key, required this.slug});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Producto'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          Can(
            permissionCode: 'productos.editar',
            child: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/products/${widget.slug}/edit');
              },
              tooltip: 'Editar',
            ),
          ),
          Can(
            permissionCode: 'productos.eliminar',
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
              tooltip: 'Eliminar',
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _loadProduct(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.hasError
                        ? snapshot.error.toString()
                        : 'No se pudo cargar el producto',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final product = snapshot.data!;
          return _buildProductDetail(context, product);
        },
      ),
    );
  }

  Future<Product> _loadProduct() async {
    final getProductUseCase = ref.read(getProductUseCaseProvider);
    final result = await getProductUseCase(widget.slug);

    return result.fold(
      (failure) => throw _getFailureMessage(failure),
      (product) => product,
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Está seguro que desea eliminar este producto?\n\n'
          'Esta acción no se puede deshacer.',
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

    if (confirmed == true && context.mounted) {
      await _deleteProduct(context);
    }
  }

  Future<void> _deleteProduct(BuildContext context) async {
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final deleteUseCase = ref.read(deleteProductUseCaseProvider);
    final result = await deleteUseCase(widget.slug);

    // Cerrar indicador de carga
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    result.fold(
      (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al eliminar: ${_getFailureMessage(failure)}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      },
      (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto eliminado exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Regresar a la lista
          context.go('/products');
        }
      },
    );
  }

  Widget _buildProductDetail(BuildContext context, Product product) {
    final images = product.imagenes;
    final hasImages = images.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Galería de imágenes
          if (hasImages) ...[
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    _selectedImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    images[index].url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported, size: 80),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Indicadores de página
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _selectedImageIndex
                        ? Colors.deepPurple
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ] else
            Container(
              height: 200,
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(Icons.checkroom, size: 80, color: Colors.grey),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre y precio
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.nombre,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      product.precio.formato,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Marca y categoría
                Row(
                  children: [
                    const Icon(Icons.business, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      product.marca.nombre,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.category, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      product.categoria.nombre,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Badges (flags)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (!product.activo)
                      _Badge(
                        label: 'Inactiva',
                        color: Colors.red,
                        icon: Icons.visibility_off,
                      ),
                    // Nota: Agregar badges para destacada/novedad si existen en el dominio
                    _Badge(
                      label: 'Stock: ${product.stock}',
                      color: product.stock > 0 ? Colors.green : Colors.orange,
                      icon: Icons.inventory_2,
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Descripción
                const Text(
                  'Descripción',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  product.descripcion,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),

                const SizedBox(height: 24),

                // Tallas disponibles
                if (product.tallas.isNotEmpty) ...[
                  const Text(
                    'Tallas Disponibles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.tallas.map((size) {
                      return Chip(
                        label: Text(size.nombre),
                        avatar: const Icon(Icons.straighten, size: 16),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Información adicional
                if (product.material != null ||
                    product.genero != null ||
                    product.color != null ||
                    product.temporada != null) ...[
                  const Text(
                    'Información Adicional',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _InfoTable([
                    if (product.material != null)
                      _InfoRow(label: 'Material', value: product.material!),
                    if (product.genero != null)
                      _InfoRow(label: 'Género', value: product.genero!),
                    if (product.color != null)
                      _InfoRow(label: 'Color', value: product.color!),
                    if (product.temporada != null)
                      _InfoRow(label: 'Temporada', value: product.temporada!),
                    _InfoRow(label: 'Código', value: product.codigo),
                    _InfoRow(label: 'Slug', value: product.slug),
                  ]),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFailureMessage(Failure failure) {
    return failure.when(
      validation: (message, errors) => message,
      auth: (message, statusCode) => message,
      server: (message, statusCode) => message,
      network: (message, statusCode) => message,
      notFound: (message, statusCode) => message,
      unknown: (message) => message,
    );
  }
}

/// Widget para mostrar un badge/etiqueta
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Badge({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tabla de información
class _InfoTable extends StatelessWidget {
  final List<Widget> rows;

  const _InfoTable(this.rows);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: rows),
    );
  }
}

/// Fila de información
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
