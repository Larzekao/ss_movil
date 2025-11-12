import 'package:ss_movil/features/accounts/domain/entities/user.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/user_dto.dart';

/// Mapper: UserDto ↔ User
extension UserMapper on UserDto {
  User toEntity() {
    return User(
      id: id,
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
