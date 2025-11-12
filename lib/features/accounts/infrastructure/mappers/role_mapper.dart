import 'package:ss_movil/features/accounts/domain/entities/role.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/role_dto.dart';

/// Mapper: RoleDto ↔ Role
extension RoleMapper on RoleDto {
  Role toEntity() {
    return Role(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      permisos: permisos.map((p) => p.toEntity()).toList(),
      esRolSistema: esRolSistema,
    );
  }
}
