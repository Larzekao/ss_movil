import 'package:freezed_annotation/freezed_annotation.dart';

part 'image.freezed.dart';

/// Entidad ProductImage (Domain)
@freezed
class ProductImage with _$ProductImage {
  const factory ProductImage({
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
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _ProductImage;

  const ProductImage._();

  /// Información del archivo de imagen
  String get infoArchivo {
    final partes = <String>[];
    if (formato != null) partes.add(formato!.toUpperCase());
    if (width != null && height != null) partes.add('${width}x$height');
    if (tamanioBytes != null) {
      final kb = (tamanioBytes! / 1024).round();
      partes.add('${kb}KB');
    }
    return partes.isEmpty ? 'Imagen' : partes.join(' • ');
  }

  /// Verifica si es una imagen válida
  bool get esValida => url.isNotEmpty && altText.isNotEmpty;
}
