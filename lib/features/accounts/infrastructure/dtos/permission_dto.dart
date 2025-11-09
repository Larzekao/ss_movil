import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ss_movil/features/accounts/domain/entities/permission.dart';

part 'permission_dto.freezed.dart';

/// DTO para Permission (Infrastructure)
@freezed
class PermissionDto with _$PermissionDto {
  const PermissionDto._();

  const factory PermissionDto({
    required String id,
    required String codigo,
    required String nombre,
    required String modulo,
    String? descripcion,
  }) = _PermissionDto;

  factory PermissionDto.fromJson(Map<String, dynamic> json) {
    return PermissionDto(
      id: json['id'] as String,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      modulo: json['modulo'] as String,
      descripcion: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'codigo': codigo,
    'nombre': nombre,
    'modulo': modulo,
    'descripcion': descripcion,
  };

  /// Convierte el DTO a entidad de dominio
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
