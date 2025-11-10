import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ss_movil/features/products/domain/entities/image.dart';

part 'image_dto.freezed.dart';

/// DTO para ProductImage (Infrastructure)
@Freezed(fromJson: false, toJson: false)
class ImageDto with _$ImageDto {
  const factory ImageDto({
    required String id,
    required String url,
    required String altText,
    @Default(false) bool esPrincipal,
    @Default(0) int orden,
    String? titulo,
    String? descripcion,
    int? width,
    int? height,
    String? formato,
    int? tamanioBytes,
    @Default('') String createdAt,
    String? updatedAt,
  }) = _ImageDto;

  const ImageDto._();

  /// Crea DTO desde JSON del backend
  factory ImageDto.fromJson(Map<String, dynamic> json) {
    return _ImageDto(
      id: json['id'] as String,
      url: json['url'] as String,
      altText: json['alt_text'] as String? ?? '',
      esPrincipal: json['es_principal'] as bool? ?? false,
      orden: json['orden'] as int? ?? 0,
      titulo: json['titulo'] as String?,
      descripcion: json['descripcion'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      formato: json['formato'] as String?,
      tamanioBytes: json['tamanio_bytes'] as int?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Convierte DTO a entidad del dominio
  ProductImage toEntity() {
    return ProductImage(
      id: id,
      url: url,
      altText: altText,
      esPrincipal: esPrincipal,
      orden: orden,
      titulo: titulo,
      descripcion: descripcion,
      width: width,
      height: height,
      formato: formato,
      tamanioBytes: tamanioBytes,
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
  factory ImageDto.fromEntity(ProductImage entity) {
    return ImageDto(
      id: entity.id,
      url: entity.url,
      altText: entity.altText,
      esPrincipal: entity.esPrincipal,
      orden: entity.orden,
      titulo: entity.titulo,
      descripcion: entity.descripcion,
      width: entity.width,
      height: entity.height,
      formato: entity.formato,
      tamanioBytes: entity.tamanioBytes,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }
}
