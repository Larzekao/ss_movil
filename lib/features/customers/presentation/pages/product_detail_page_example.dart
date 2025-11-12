import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/features/customers/presentation/widgets/favorite_button.dart';

/// Ejemplo de ProductDetailPage con botón de favorito integrado
///
/// Este es un scaffold básico que muestra cómo usar FavoriteButton
/// en la página de detalles de un producto.
class ProductDetailPageExample extends ConsumerWidget {
  final int productId;
  final String productName;
  final String productDescription;
  final double productPrice;
  final String? productImage;

  const ProductDetailPageExample({
    super.key,
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    this.productImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FavoriteButton(
              productId: productId,
              size: 28,
              onError: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo guardar el favorito'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[300],
              child: productImage != null
                  ? Image.network(
                      productImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.image,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                    ),
            ),

            // Información del producto
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y precio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          productName,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '\$${productPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Descripción
                  Text(
                    'Descripción',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  // Rating (placeholder)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '4.5 (128 reviews)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Botón de compra
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Lógica de agregar al carrito
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Producto agregado al carrito'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Agregar al Carrito'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botón secundario con el widget FavoriteButton
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navegar a favoritos
                        // context.push('/favorites');
                      },
                      icon: const Icon(Icons.favorite),
                      label: const Text('Ver todos los favoritos'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Uso en la aplicación:
///
/// // En tu router/navigation:
/// GoRoute(
///   path: '/product/:id',
///   builder: (context, state) {
///     final id = int.parse(state.pathParameters['id']!);
///     return ProductDetailPageExample(
///       productId: id,
///       productName: 'Producto Ejemplo',
///       productDescription: 'Descripción del producto',
///       productPrice: 99.99,
///     );
///   },
/// ),
