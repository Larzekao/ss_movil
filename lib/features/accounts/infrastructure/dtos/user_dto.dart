import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ss_movil/features/accounts/domain/entities/user.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/role_dto.dart';

part 'user_dto.freezed.dart';

/// DTO para User (Infrastructure)
@freezed
class UserDto with _$UserDto {
  const UserDto._();

  const factory UserDto({
    required String id,
    required String email,
    required String nombre,
    required String apellido,
    String? nombreCompleto,
    String? telefono,
    String? fotoPerfil,
    required RoleDto rol,
    String? codigoEmpleado,
    @Default(0.0) double saldoBilletera,
    @Default(true) bool activo,
    @Default(false) bool emailVerificado,
    required String createdAt,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    // Helper para convertir saldo de forma segura
    double parseSaldo(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (_) {
          return 0.0;
        }
      }
      return 0.0;
    }

    return UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      nombreCompleto: json['nombre_completo'] as String?,
      telefono: json['telefono'] as String?,
      fotoPerfil: json['foto_perfil'] as String?,
      rol: RoleDto.fromJson(json['rol_detalle'] as Map<String, dynamic>),
      codigoEmpleado: json['codigo_empleado'] as String?,
      saldoBilletera: parseSaldo(json['saldo_billetera']),
      activo: json['activo'] as bool? ?? true,
      emailVerificado: json['email_verificado'] as bool? ?? false,
      createdAt:
          json['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'nombre': nombre,
    'apellido': apellido,
    'nombre_completo': nombreCompleto,
    'telefono': telefono,
    'foto_perfil': fotoPerfil,
    'rol_detalle': rol.toJson(),
    'codigo_empleado': codigoEmpleado,
    'saldo_billetera': saldoBilletera,
    'activo': activo,
    'email_verificado': emailVerificado,
    'created_at': createdAt,
  };

  /// Convierte el DTO a entidad de dominio
  User toEntity() {
    return User(
      id: id.toString(),
      email: email,
      nombre: nombre,
      apellido: apellido,
      telefono: telefono,
      fotoPerfil: fotoPerfil,
      rol: rol.toEntity(),
      codigoEmpleado: codigoEmpleado,
      saldoBilletera: saldoBilletera,
      activo: activo,
      emailVerificado: emailVerificado,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
