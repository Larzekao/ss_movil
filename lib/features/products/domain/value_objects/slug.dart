import 'package:freezed_annotation/freezed_annotation.dart';

part 'slug.freezed.dart';

/// Value Object para slugs de URL
@freezed
class Slug with _$Slug {
  const factory Slug({required String value}) = _Slug;

  const Slug._();

  /// Crea un slug desde un texto
  factory Slug.fromText(String text) {
    final slug = _slugify(text);
    return Slug(value: slug);
  }

  /// Valida que el slug sea válido
  factory Slug.validated(String value) {
    if (!_isValidSlug(value)) {
      throw ArgumentError('Slug inválido: $value');
    }
    return Slug(value: value);
  }

  /// Convierte texto a formato slug
  static String _slugify(String text) {
    return text
        .toLowerCase()
        .trim()
        // Reemplazar caracteres especiales del español
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ü', 'u')
        // Eliminar caracteres no alfanuméricos excepto espacios y guiones
        .replaceAll(RegExp(r'[^a-z0-9\s\-_]'), '')
        // Reemplazar espacios múltiples con uno solo
        .replaceAll(RegExp(r'\s+'), ' ')
        // Reemplazar espacios con guiones
        .replaceAll(' ', '-')
        // Eliminar guiones múltiples
        .replaceAll(RegExp(r'-+'), '-')
        // Eliminar guiones al inicio y final
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  /// Valida formato de slug
  static bool _isValidSlug(String value) {
    if (value.isEmpty) return false;
    // Solo letras minúsculas, números y guiones
    // No puede empezar o terminar con guión
    final regex = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
    return regex.hasMatch(value);
  }

  /// Verifica si el slug es válido
  bool get isValid => _isValidSlug(value);

  /// Longitud del slug
  int get length => value.length;

  /// Verifica si está vacío
  bool get isEmpty => value.isEmpty;

  /// Verifica si no está vacío
  bool get isNotEmpty => value.isNotEmpty;

  @override
  String toString() => value;
}
