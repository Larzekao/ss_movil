import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ss_movil/features/products/domain/entities/brand.dart';

part 'brand_dto.freezed.dart';

/// DTO para Brand (Infrastructure)
@Freezed(fromJson: false, toJson: false)
class BrandDto with _$BrandDto {
  const factory BrandDto({
    required String id,
    required String nombre,
    String? slug,
    String? descripcion,
    String? logo,
    String? sitioWeb,
    @Default(true) bool activo,
    @Default(0) int totalPrendas,
    @Default('') String createdAt,
    String? updatedAt,
  }) = _BrandDto;

  const BrandDto._();

  /// Crea DTO desde JSON del backend
  factory BrandDto.fromJson(Map<String, dynamic> json) {
    try {
      return _BrandDto(
        id: json['id'] as String? ?? '',
        nombre: json['nombre'] as String? ?? '',
        slug: json['slug'] as String?,
        descripcion: json['descripcion'] as String?,
        logo: json['logo'] as String?,
        sitioWeb: json['sitio_web'] as String?,
        activo: json['activo'] as bool? ?? true,
        totalPrendas: json['total_prendas'] as int? ?? 0,
        createdAt: json['created_at'] as String? ?? '',
        updatedAt: json['updated_at'] as String?,
      );
    } catch (e) {
      print('Error parsing BrandDto: $e');
      return _BrandDto(
        id: json['id'] as String? ?? '',
        nombre: json['nombre'] as String? ?? '',
      );
    }
  }

  /// Convierte DTO a entidad del dominio
  Brand toEntity() {
    return Brand(
      id: id,
      nombre: nombre,
      slug: slug ?? '',
      descripcion: descripcion,
      logo: logo,
      sitioWeb: sitioWeb,
      activo: activo,
      createdAt: _parseDateTime(createdAt),
      updatedAt: updatedAt != null ? _parseDateTime(updatedAt!) : null,
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
  factory BrandDto.fromEntity(Brand entity) {
    return BrandDto(
      id: entity.id,
      nombre: entity.nombre,
      slug: entity.slug,
      descripcion: entity.descripcion,
      logo: entity.logo,
      sitioWeb: entity.sitioWeb,
      activo: entity.activo,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }
}
