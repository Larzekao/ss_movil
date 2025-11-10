import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/entities/product.dart';

/// Repository contract para Products (Domain)
abstract class ProductsRepository {
  /// Lista productos paginados con filtros opcionales
  Future<Either<Failure, PagedProducts>> listProducts({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    String? brandId,
    double? minPrice,
    double? maxPrice,
    bool? isActive,
    String? orderBy,
  });

  /// Obtiene un producto por ID
  Future<Either<Failure, Product>> getProduct(String id);

  /// Crea un nuevo producto
  Future<Either<Failure, Product>> createProduct(CreateProductRequest request);

  /// Actualiza un producto existente
  Future<Either<Failure, Product>> updateProduct(
    String id,
    UpdateProductRequest request,
  );

  /// Elimina un producto
  Future<Either<Failure, void>> deleteProduct(String id);
}

/// Resultado paginado de productos
class PagedProducts {
  final int count;
  final String? next;
  final String? previous;
  final List<Product> results;

  const PagedProducts({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });
}

/// Request para crear producto
class CreateProductRequest {
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final String codigo;
  final String categoryId;
  final String brandId;
  final List<String> sizeIds;
  final String? material;
  final String? genero;
  final String? temporada;
  final String? color;
  final Map<String, dynamic>? metadatos;
  final String? imagenPath; // Ruta del archivo de imagen seleccionado

  const CreateProductRequest({
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.codigo,
    required this.categoryId,
    required this.brandId,
    required this.sizeIds,
    this.material,
    this.genero,
    this.temporada,
    this.color,
    this.metadatos,
    this.imagenPath,
  });
}

/// Request para actualizar producto
class UpdateProductRequest {
  final String? nombre;
  final String? descripcion;
  final double? precio;
  final int? stock;
  final String? codigo;
  final String? categoryId;
  final String? brandId;
  final List<String>? sizeIds;
  final bool? activo;
  final String? material;
  final String? genero;
  final String? temporada;
  final String? color;
  final Map<String, dynamic>? metadatos;

  const UpdateProductRequest({
    this.nombre,
    this.descripcion,
    this.precio,
    this.stock,
    this.codigo,
    this.categoryId,
    this.brandId,
    this.sizeIds,
    this.activo,
    this.material,
    this.genero,
    this.temporada,
    this.color,
    this.metadatos,
  });
}
