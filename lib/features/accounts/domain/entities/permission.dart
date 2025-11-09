import 'package:freezed_annotation/freezed_annotation.dart';

part 'permission.freezed.dart';

/// Entidad Permission (Domain)
@freezed
class Permission with _$Permission {
  const factory Permission({
    required String id,
    required String codigo,
    required String nombre,
    required String modulo,
    String? descripcion,
  }) = _Permission;
}
