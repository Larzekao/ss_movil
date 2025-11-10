import 'package:freezed_annotation/freezed_annotation.dart';

part 'brand.freezed.dart';

/// Entidad Brand (Domain)
@freezed
class Brand with _$Brand {
  const factory Brand({
    required String id,
    required String nombre,
    required String slug,
    String? descripcion,
    String? logo,
    String? sitioWeb,
    @Default(true) bool activo,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Brand;

  const Brand._();

  /// URL del logo por defecto si no tiene
  String get logoUrl => logo ?? '/images/brands/default.png';

  /// Indica si tiene sitio web
  bool get tieneSitioWeb => sitioWeb != null && sitioWeb!.isNotEmpty;
}
