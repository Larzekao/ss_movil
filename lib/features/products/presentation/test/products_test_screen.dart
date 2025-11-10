import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/features/products/application/providers/products_providers.dart';
import 'package:ss_movil/features/products/application/usecases/products/list_products.dart';

/// Snippet temporal para probar list_products UseCase
///
/// PARA PROBAR:
/// 1. Asegúrate que el backend esté corriendo en localhost:8000
/// 2. Ejecuta esta función desde algún widget o botón temporal
/// 3. Verifica que obtienes count y results reales
class ProductsTestScreen extends ConsumerWidget {
  const ProductsTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Products P1')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _testListProducts(ref);
              },
              child: const Text('Test List Products'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _testGetProduct(ref);
              },
              child: const Text('Test Get Product by Slug'),
            ),
          ],
        ),
      ),
    );
  }

  /// Prueba el listado de productos
  Future<void> _testListProducts(WidgetRef ref) async {
    debugPrint('🔵 [TEST] Iniciando test de listProducts...');

    final listProductsUseCase = ref.read(listProductsUseCaseProvider);

    final params = const ListProductsParams(page: 1, limit: 10);

    final result = await listProductsUseCase(params);

    result.fold(
      (failure) {
        debugPrint('❌ [TEST] Error al listar productos:');
        debugPrint('   Tipo: ${failure.runtimeType}');
        debugPrint('   Mensaje: ${_getFailureMessage(failure)}');
      },
      (pagedProducts) {
        debugPrint('✅ [TEST] Productos listados exitosamente:');
        debugPrint('   Count: ${pagedProducts.count}');
        debugPrint('   Next: ${pagedProducts.next}');
        debugPrint('   Previous: ${pagedProducts.previous}');
        debugPrint('   Results: ${pagedProducts.results.length} productos');

        if (pagedProducts.results.isNotEmpty) {
          final firstProduct = pagedProducts.results.first;
          debugPrint('');
          debugPrint('   Primer producto:');
          debugPrint('   - ID: ${firstProduct.id}');
          debugPrint('   - Nombre: ${firstProduct.nombre}');
          debugPrint('   - Slug: ${firstProduct.slug}');
          debugPrint('   - Precio: ${firstProduct.precioFormateado}');
          debugPrint('   - Stock: ${firstProduct.stock}');
          debugPrint('   - Disponible: ${firstProduct.estaDisponible}');
          debugPrint('   - Categoría: ${firstProduct.categoria.nombre}');
          debugPrint('   - Marca: ${firstProduct.marca.nombre}');
          debugPrint(
            '   - Tallas: ${firstProduct.tallas.map((t) => t.nombre).join(", ")}',
          );
          debugPrint(
            '   - Imagen principal: ${firstProduct.urlImagenPrincipal}',
          );
        }
      },
    );
  }

  /// Prueba obtener un producto por slug
  Future<void> _testGetProduct(WidgetRef ref) async {
    debugPrint('🔵 [TEST] Iniciando test de getProduct...');

    final getProductUseCase = ref.read(getProductUseCaseProvider);

    // Primero obtener un slug real de la lista
    final listProductsUseCase = ref.read(listProductsUseCaseProvider);
    final listResult = await listProductsUseCase(
      const ListProductsParams(page: 1, limit: 1),
    );

    String? slug;
    listResult.fold(
      (failure) => debugPrint('❌ [TEST] Error al obtener productos para test'),
      (pagedProducts) {
        if (pagedProducts.results.isNotEmpty) {
          slug = pagedProducts.results.first.slug;
        }
      },
    );

    if (slug == null) {
      debugPrint('❌ [TEST] No hay productos para probar getProduct');
      return;
    }

    debugPrint('🔵 [TEST] Obteniendo producto con slug: $slug');

    final result = await getProductUseCase(slug!);

    result.fold(
      (failure) {
        debugPrint('❌ [TEST] Error al obtener producto:');
        debugPrint('   Tipo: ${failure.runtimeType}');
        debugPrint('   Mensaje: ${_getFailureMessage(failure)}');
      },
      (product) {
        debugPrint('✅ [TEST] Producto obtenido exitosamente:');
        debugPrint('   ID: ${product.id}');
        debugPrint('   Nombre: ${product.nombre}');
        debugPrint('   Descripción: ${product.descripcion}');
        debugPrint('   Slug: ${product.slug}');
        debugPrint('   Precio: ${product.precioFormateado}');
        debugPrint('   Stock: ${product.stock}');
        debugPrint('   Código: ${product.codigo}');
        debugPrint('   Disponible: ${product.estaDisponible}');
        debugPrint('   Categoría: ${product.categoria.nombre}');
        debugPrint('   Marca: ${product.marca.nombre}');
        debugPrint('   Material: ${product.material ?? "N/A"}');
        debugPrint('   Género: ${product.genero ?? "N/A"}');
        debugPrint('   Color: ${product.color ?? "N/A"}');
        debugPrint(
          '   Tallas (${product.tallas.length}): ${product.tallas.map((t) => t.nombre).join(", ")}',
        );
        debugPrint('   Imágenes: ${product.imagenes.length}');
      },
    );
  }

  /// Extrae el mensaje de un Failure
  String _getFailureMessage(dynamic failure) {
    return failure.when(
      network: (message, statusCode) => message,
      auth: (message, statusCode) => message,
      server: (message, statusCode) => message,
      validation: (message, errors) => message,
      unknown: (message) => message,
    );
  }
}
