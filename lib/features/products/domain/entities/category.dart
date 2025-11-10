import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

/// Entidad Category (Domain)
@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String nombre,
    required String slug,
    String? descripcion,
    String? imagen,
    String? icono,
    String? color,
    @Default(true) bool activo,
    @Default(0) int orden,
    String? categoriasPadreId,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Category;

  const Category._();

  /// Verifica si es una categoría raíz (sin padre)
  bool get esRaiz => categoriasPadreId == null;

  /// URL de imagen por defecto si no tiene
  String get imagenUrl => imagen ?? '/images/categories/default.png';
}
