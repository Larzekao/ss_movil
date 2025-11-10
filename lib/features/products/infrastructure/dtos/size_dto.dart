import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ss_movil/features/products/domain/entities/size.dart';

part 'size_dto.freezed.dart';

/// DTO para Size (Infrastructure)
@Freezed(fromJson: false, toJson: false)
class SizeDto with _$SizeDto {
  const factory SizeDto({
    required String id,
    required String nombre,
    required String codigo,
    String? descripcion,
    @Default(0) int orden,
    @Default(true) bool activo,
    @Default('') String createdAt,
    String? updatedAt,
  }) = _SizeDto;

  const SizeDto._();

  /// Crea DTO desde JSON del backend
  factory SizeDto.fromJson(Map<String, dynamic> json) {
    return _SizeDto(
      id: (json['id'] as String?)?.trim() ?? '',
      nombre: (json['nombre'] as String?)?.trim() ?? '',
      codigo: (json['codigo'] as String?)?.trim() ?? '',
      descripcion: (json['descripcion'] as String?)?.trim(),
      orden: json['orden'] as int? ?? 0,
      activo: json['activo'] as bool? ?? true,
      createdAt: (json['created_at'] as String?)?.trim() ?? '',
      updatedAt: (json['updated_at'] as String?)?.trim(),
    );
  }

  /// Convierte DTO a entidad del dominio
  Size toEntity() {
    return Size(
      id: id,
      nombre: nombre,
      codigo: codigo,
      descripcion: descripcion,
      orden: orden,
      activo: activo,
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
  factory SizeDto.fromEntity(Size entity) {
    return SizeDto(
      id: entity.id,
      nombre: entity.nombre,
      codigo: entity.codigo,
      descripcion: entity.descripcion,
      orden: entity.orden,
      activo: entity.activo,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }
}
