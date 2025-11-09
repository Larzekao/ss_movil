import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ss_movil/features/accounts/domain/entities/permission.dart';

part 'role.freezed.dart';

/// Entidad Role (Domain)
@freezed
class Role with _$Role {
  const factory Role({
    required String id,
    required String nombre,
    String? descripcion,
    required List<Permission> permisos,
    required bool esRolSistema,
  }) = _Role;
}
