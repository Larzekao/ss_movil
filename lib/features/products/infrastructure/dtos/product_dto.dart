import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ss_movil/features/products/domain/entities/product.dart';
import 'package:ss_movil/features/products/domain/entities/category.dart';
import 'package:ss_movil/features/products/domain/entities/brand.dart';
import 'package:ss_movil/features/products/domain/value_objects/money.dart';
import 'package:ss_movil/features/products/infrastructure/dtos/category_dto.dart';
import 'package:ss_movil/features/products/infrastructure/dtos/brand_dto.dart';
import 'package:ss_movil/features/products/infrastructure/dtos/size_dto.dart';
import 'package:ss_movil/features/products/infrastructure/dtos/image_dto.dart';

part 'product_dto.freezed.dart';

/// DTO para Product (Infrastructure)
@Freezed(fromJson: false, toJson: false)
class ProductDto with _$ProductDto {
  const factory ProductDto({
    required String id,
    required String nombre,
    @Default('') String descripcion,
    required String precio,
    @Default([]) List<CategoryDto> categorias,
    String? categoriaNombre,
    BrandDto? marca,
    String? marcaNombre,
    @Default([]) List<SizeDto> tallas,
    @Default([]) List<SizeDto> tallasDisponiblesDetalle,
    ImageDto? imagenPrincipal,
    @Default(true) bool activa,
    String? material,
    String? genero,
    String? temporada,
    String? color,
    @Default(0) int stockTotal,
    @Default(false) bool destacada,
    @Default(false) bool esNovedad,
    @Default('') String slug,
    String? codigo,
    Map<String, dynamic>? metadatos,
    String? createdAt,
    String? updatedAt,
  }) = _ProductDto;

  const ProductDto._();

  /// Crea DTO desde JSON del backend
  factory ProductDto.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parseando producto: ${json['nombre']}');

      // Convertir precio a String (puede venir como num o String del backend)
      final precioValue = json['precio'];
      final precioString = precioValue != null ? precioValue.toString() : '0.0';

      print('  ✓ precio: $precioString');

      // Procesar tallas_disponibles_detalle (lista con objetos SizeDto)
      List<SizeDto> tallasDisp = [];
      try {
        final tallasList = json['tallas_disponibles_detalle'] as List<dynamic>?;
        if (tallasList != null) {
          tallasDisp = tallasList
              .map((e) => SizeDto.fromJson(e as Map<String, dynamic>))
              .toList();
          print('  ✓ tallas_disponibles_detalle: ${tallasDisp.length}');
        }
      } catch (e) {
        print('  ⚠️ Error parseando tallas_disponibles_detalle: $e');
      }

      // Procesar marca - puede venir como:
      // 1. Objeto Map con estructura de BrandDto (en lista)
      // 2. String UUID (en detalle)
      // 3. null
      BrandDto? marcaDto;
      try {
        if (json['marca'] is Map<String, dynamic>) {
          // Caso 1: Es un objeto (lista)
          marcaDto = BrandDto.fromJson(json['marca'] as Map<String, dynamic>);
        } else if (json['marca_detalle'] is Map<String, dynamic>) {
          // Caso alternativo: marca_detalle en detalle endpoint
          marcaDto = BrandDto.fromJson(
            json['marca_detalle'] as Map<String, dynamic>,
          );
        }
      } catch (e) {
        print('  ⚠️ Error parseando marca: $e');
      }

      // Procesar categorías - puede venir como:
      // 1. Array de objetos CategoryDto (en lista)
      // 2. Array de strings UUID (en detalle como categorias)
      // 3. Array de objetos CategoryDto (en detalle como categorias_detalle)
      List<CategoryDto> categoriasDto = [];
      try {
        final categoriasField = json['categorias'] as List<dynamic>?;
        final categoriasDetalleField =
            json['categorias_detalle'] as List<dynamic>?;

        if (categoriasDetalleField != null &&
            categoriasDetalleField.isNotEmpty) {
          // Preferir categorias_detalle si contiene objetos
          if (categoriasDetalleField.first is Map<String, dynamic>) {
            categoriasDto = categoriasDetalleField
                .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
                .toList();
            print('  ✓ categorias_detalle: ${categoriasDto.length}');
          }
        } else if (categoriasField != null && categoriasField.isNotEmpty) {
          // Si categorias tiene objetos, procesarlos
          if (categoriasField.first is Map<String, dynamic>) {
            categoriasDto = categoriasField
                .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
                .toList();
            print('  ✓ categorias (como objetos): ${categoriasDto.length}');
          }
          // Si son strings, ignorarlos (no podemos hacer nada sin el objeto)
        }
      } catch (e) {
        print('  ⚠️ Error parseando categorías: $e');
      }

      return _ProductDto(
        id: (json['id'] as String?)?.trim() ?? '',
        nombre: (json['nombre'] as String?)?.trim() ?? '',
        descripcion: (json['descripcion'] as String?)?.trim() ?? '',
        precio: precioString,
        categorias: categoriasDto,
        categoriaNombre: (json['categoria_nombre'] as String?)?.trim(),
        marca: marcaDto,
        marcaNombre: (json['marca_nombre'] as String?)?.trim(),
        tallas:
            (json['tallas'] as List<dynamic>?)
                ?.map((e) => SizeDto.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        tallasDisponiblesDetalle: tallasDisp,
        imagenPrincipal: (json['imagen_principal'] is Map<String, dynamic>)
            ? ImageDto.fromJson(
                json['imagen_principal'] as Map<String, dynamic>,
              )
            : null,
        activa: json['activa'] as bool? ?? true,
        material: (json['material'] as String?)?.trim(),
        genero: (json['genero'] as String?)?.trim(),
        temporada: (json['temporada'] as String?)?.trim(),
        color: (json['color'] as String?)?.trim(),
        stockTotal: json['stock_total'] as int? ?? 0,
        destacada: json['destacada'] as bool? ?? false,
        esNovedad: json['es_novedad'] as bool? ?? false,
        slug: (json['slug'] as String?)?.trim() ?? '',
        codigo: (json['codigo'] as String?)?.trim(),
        metadatos: json['metadata'] is Map<String, dynamic>
            ? json['metadata'] as Map<String, dynamic>
            : null,
        createdAt: (json['created_at'] as String?)?.trim(),
        updatedAt: (json['updated_at'] as String?)?.trim(),
      );
    } catch (e) {
      print('❌ ERROR en ProductDto.fromJson: $e');
      print('JSON recibido: $json');
      rethrow;
    }
  }

  /// Convierte DTO a entidad del dominio
  Product toEntity() {
    try {
      print('🔄 Convirtiendo a entidad: $nombre');

      // Parsear precio de string a double
      final precioDouble = double.tryParse(precio) ?? 0.0;

      // Usar tallas de tallasDisponiblesDetalle si está disponible, sino usar tallas
      final tallasFinales = tallasDisponiblesDetalle.isNotEmpty
          ? tallasDisponiblesDetalle
          : tallas;

      // Parsear fechas con logging
      DateTime parsedCreatedAt;
      DateTime? parsedUpdatedAt;

      try {
        parsedCreatedAt = createdAt != null
            ? _parseDateTime(createdAt!)
            : DateTime.now();
        print('  ✓ createdAt parseado: $parsedCreatedAt');
      } catch (e) {
        print('  ❌ Error parseando createdAt: $e');
        parsedCreatedAt = DateTime.now();
      }

      try {
        parsedUpdatedAt = updatedAt != null ? _parseDateTime(updatedAt!) : null;
        if (parsedUpdatedAt != null) {
          print('  ✓ updatedAt parseado: $parsedUpdatedAt');
        }
      } catch (e) {
        print('  ❌ Error parseando updatedAt: $e');
        parsedUpdatedAt = null;
      }

      return Product(
        id: id,
        nombre: nombre,
        descripcion: descripcion.isNotEmpty ? descripcion : 'Sin descripción',
        precio: Money(cantidad: precioDouble, moneda: 'BOB'),
        stock: stockTotal,
        codigo: codigo ?? '',
        slug: slug,
        categoria: categorias.isNotEmpty
            ? categorias.first.toEntity()
            : _createDefaultCategoryFromNombre(categoriaNombre),
        marca: marca?.toEntity() ?? _createDefaultBrandFromNombre(marcaNombre),
        tallas: tallasFinales.map((dto) => dto.toEntity()).toList(),
        imagenes: imagenPrincipal != null ? [imagenPrincipal!.toEntity()] : [],
        activo: activa,
        material: material,
        genero: genero,
        temporada: temporada,
        color: color,
        metadatos: metadatos,
        createdAt: parsedCreatedAt,
        updatedAt: parsedUpdatedAt,
      );
    } catch (e, stackTrace) {
      print('❌ ERROR en toEntity() para producto $nombre: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Parsea DateTime de forma segura manejando diferentes formatos
  static DateTime _parseDateTime(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // Si falla el parseo, intentar con tryParse
      final parsed = DateTime.tryParse(dateString);
      if (parsed != null) return parsed;

      // Si aún falla, retornar fecha actual
      print('⚠️ Error parseando fecha: $dateString - usando DateTime.now()');
      return DateTime.now();
    }
  }

  /// Categoría por defecto cuando no hay categoría, usando categoriaNombre si está disponible
  static Category _createDefaultCategoryFromNombre(String? categoriaNombre) {
    final nombreFinal = categoriaNombre?.isNotEmpty == true
        ? categoriaNombre!
        : 'Sin categoría';
    return Category(
      id: '',
      nombre: nombreFinal,
      slug: nombreFinal.toLowerCase().replaceAll(' ', '-'),
      activo: true,
      orden: 0,
      createdAt: DateTime.now(),
    );
  }

  /// Marca por defecto cuando no hay marca, usando marcaNombre si está disponible
  static Brand _createDefaultBrandFromNombre(String? marcaNombre) {
    final nombreFinal = marcaNombre?.isNotEmpty == true
        ? marcaNombre!
        : 'Sin marca';
    return Brand(
      id: '',
      nombre: nombreFinal,
      slug: nombreFinal.toLowerCase().replaceAll(' ', '-'),
      activo: true,
      createdAt: DateTime.now(),
    );
  }

  /// Crea DTO desde entidad del dominio
  factory ProductDto.fromEntity(Product entity) {
    return ProductDto(
      id: entity.id,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      precio: entity.precio.cantidad.toStringAsFixed(2),
      slug: entity.slug,
      categorias: [CategoryDto.fromEntity(entity.categoria)],
      marca: BrandDto.fromEntity(entity.marca),
      tallas: entity.tallas.map((e) => SizeDto.fromEntity(e)).toList(),
      imagenPrincipal: entity.imagenes.isNotEmpty
          ? ImageDto.fromEntity(entity.imagenes.first)
          : null,
      activa: entity.activo,
      material: entity.material,
      genero: entity.genero,
      temporada: entity.temporada,
      color: entity.color,
      stockTotal: entity.stock,
      codigo: entity.codigo,
      metadatos: entity.metadatos,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }
}

/// DTOs para crear/actualizar productos
class CreateProductDto {
  final String nombre;
  final String descripcion;
  final String precio;
  final int stock;
  final String codigo;
  final String categoryId;
  final String brandId;
  final List<String> sizeIds;
  final String? material;
  final String? genero;
  final String? temporada;
  final String? color;
  final String? imagenPath; // Ruta del archivo de imagen

  const CreateProductDto({
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
    this.imagenPath,
  });

  /// Verifica si hay una imagen para subir
  bool get hasImage => imagenPath != null && imagenPath!.isNotEmpty;

  // Getter para compatibilidad
  bool get tieneImagen => hasImage;

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'descripcion': descripcion,
    'precio': precio,
    'stock': stock,
    'codigo': codigo,
    'categoria': categoryId,
    'marca': brandId,
    'tallas_disponibles': sizeIds,
    'material': material,
    'genero': genero,
    'temporada': temporada,
    'color': color,
  };
}

class UpdateProductDto {
  final String? nombre;
  final String? descripcion;
  final String? precio;
  final String? material;
  final String? color;
  final bool? activa;

  const UpdateProductDto({
    this.nombre,
    this.descripcion,
    this.precio,
    this.material,
    this.color,
    this.activa,
  });

  Map<String, dynamic> toJson() => {
    if (nombre != null) 'nombre': nombre,
    if (descripcion != null) 'descripcion': descripcion,
    if (precio != null) 'precio': precio,
    if (material != null) 'material': material,
    if (color != null) 'color': color,
    if (activa != null) 'activa': activa,
  };
}
