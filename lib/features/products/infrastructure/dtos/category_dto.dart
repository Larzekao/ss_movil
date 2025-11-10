import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ss_movil/features/products/domain/entities/category.dart';

part 'category_dto.freezed.dart';

/// DTO para Category (Infrastructure)
@Freezed(fromJson: false, toJson: false)
class CategoryDto with _$CategoryDto {
  const factory CategoryDto({
    required String id,
    required String nombre,
    String? slug,
    String? descripcion,
    String? imagen,
    String? icono,
    String? color,
    @Default(true) bool activo,
    @Default(0) int orden,
    String? categoriasPadreId,
    @Default(0) int totalPrendas,
    @Default('') String createdAt,
    String? updatedAt,
  }) = _CategoryDto;

  const CategoryDto._();

  /// Crea DTO desde JSON del backend
  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return _CategoryDto(
      id: json['id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      slug: json['slug'] as String?,
      descripcion: json['descripcion'] as String?,
      imagen: json['imagen'] as String?,
      icono: json['icono'] as String?,
      color: json['color'] as String?,
      activo: (json['activa'] ?? json['activo']) as bool? ?? true, // El backend usa 'activa'
      orden: json['orden'] as int? ?? 0,
      categoriasPadreId: json['categoria_padre_id'] as String?,
      totalPrendas: json['total_prendas'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Convierte DTO a entidad del dominio
  Category toEntity() {
    return Category(
      id: id,
      nombre: nombre,
      slug: slug ?? nombre.toLowerCase().replaceAll(' ', '-'),
      descripcion: descripcion,
      imagen: imagen,
      icono: icono,
      color: color,
      activo: activo,
      orden: orden,
      categoriasPadreId: categoriasPadreId,
      createdAt: createdAt.isNotEmpty ? _parseDateTime(createdAt) : DateTime.now(),
      updatedAt: updatedAt != null && updatedAt!.isNotEmpty ? _parseDateTime(updatedAt!) : null,
    );
  }

  /// Parsea DateTime de forma segura manejando diferentes formatos
  static DateTime _parseDateTime(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      final parsed = DateTime.tryParse(dateString);
      if (parsed != null) return parsed;
      return DateTime.now();
    }
  }

  /// Crea DTO desde entidad del dominio
  factory CategoryDto.fromEntity(Category entity) {
    return CategoryDto(
      id: entity.id,
      nombre: entity.nombre,
      slug: entity.slug,
      descripcion: entity.descripcion,
      imagen: entity.imagen,
      icono: entity.icono,
      color: entity.color,
      activo: entity.activo,
      orden: entity.orden,
      categoriasPadreId: entity.categoriasPadreId,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }
}
