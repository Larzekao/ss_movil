import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ss_movil/features/products/domain/entities/category.dart';
import 'package:ss_movil/features/products/domain/entities/brand.dart';
import 'package:ss_movil/features/products/domain/entities/size.dart';
import 'package:ss_movil/features/products/domain/entities/image.dart';
import 'package:ss_movil/features/products/domain/entities/stock.dart';
import 'package:ss_movil/features/products/domain/value_objects/money.dart';

part 'product.freezed.dart';

/// Entidad Product (Domain)
@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String nombre,
    required String descripcion,
    required Money precio,
    required int stock,
    required String codigo,
    required String slug,
    required Category categoria,
    required Brand marca,
    required List<Size> tallas,
    required List<ProductImage> imagenes,
    @Default([]) List<Stock> stocks,
    @Default(true) bool activo,
    @Default(false) bool destacada,
    @Default(false) bool esNovedad,
    String? material,
    String? genero,
    String? temporada,
    String? color,
    Map<String, dynamic>? metadatos,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Product;

  const Product._();

  /// Imagen principal del producto
  ProductImage? get imagenPrincipal {
    if (imagenes.isEmpty) return null;
    final principal = imagenes.where((img) => img.esPrincipal).firstOrNull;
    return principal ?? imagenes.first;
  }

  /// URL de la imagen principal
  String? get urlImagenPrincipal => imagenPrincipal?.url;

  /// Verifica si el producto está disponible
  bool get estaDisponible => activo && stock > 0;

  /// Precio formateado
  String get precioFormateado => precio.formato;

  /// Verifica si tiene stock suficiente
  bool tieneStock(int cantidad) => stock >= cantidad;
}
