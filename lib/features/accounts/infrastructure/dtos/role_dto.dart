import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ss_movil/features/accounts/domain/entities/role.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/permission_dto.dart';

part 'role_dto.freezed.dart';

/// DTO para Role (Infrastructure)
@freezed
class RoleDto with _$RoleDto {
  const RoleDto._();

  const factory RoleDto({
    required String id,
    required String nombre,
    String? descripcion,
    required List<PermissionDto> permisos,
    required bool esRolSistema,
  }) = _RoleDto;

  factory RoleDto.fromJson(Map<String, dynamic> json) {
    return RoleDto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      permisos: (json['permisos'] as List<dynamic>)
          .map((e) => PermissionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      esRolSistema: json['es_rol_sistema'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'permisos': permisos.map((e) => e.toJson()).toList(),
    'es_rol_sistema': esRolSistema,
  };

  /// Convierte el DTO a entidad de dominio
  Role toEntity() {
    return Role(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      permisos: permisos.map((dto) => dto.toEntity()).toList(),
      esRolSistema: esRolSistema,
    );
  }
}
