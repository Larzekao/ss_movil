import 'package:freezed_annotation/freezed_annotation.dart';

part 'size.freezed.dart';

/// Entidad Size (Domain)
@freezed
class Size with _$Size {
  const factory Size({
    required String id,
    required String nombre,
    required String codigo,
    String? descripcion,
    @Default(0) int orden,
    @Default(true) bool activo,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Size;

  const Size._();

  /// Representación de texto de la talla
  String get display => '$nombre ($codigo)';

  /// Indica si es una talla estándar (S, M, L, XL, etc.)
  bool get esEstandar {
    final tallas = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'];
    return tallas.contains(codigo.toUpperCase());
  }

  /// Indica si es una talla numérica
  bool get esNumerica {
    return RegExp(r'^\d+$').hasMatch(codigo);
  }
}
