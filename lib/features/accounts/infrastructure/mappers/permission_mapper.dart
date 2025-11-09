import 'package:ss_movil/features/accounts/domain/entities/permission.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/permission_dto.dart';

/// Mapper: PermissionDto ↔ Permission
extension PermissionMapper on PermissionDto {
  Permission toEntity() {
    return Permission(
      id: id,
      codigo: codigo,
      nombre: nombre,
      modulo: modulo,
      descripcion: descripcion,
    );
  }
}
