/// DTO para actualización de usuario
///
/// Se envía al backend en PATCH /api/auth/users/{id}/
class UpdateUserDto {
  final String? email;
  final String? password;
  final String? nombre;
  final String? apellido;
  final String? telefono;
  final String? roleId;
  final String? codigoEmpleado;
  final bool? activo;
  final String? fotoPerfil;

  UpdateUserDto({
    this.email,
    this.password,
    this.nombre,
    this.apellido,
    this.telefono,
    this.roleId,
    this.codigoEmpleado,
    this.activo,
    this.fotoPerfil,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (email != null) map['email'] = email;
    if (password != null) map['password'] = password;
    if (nombre != null) map['nombre'] = nombre;
    if (apellido != null) map['apellido'] = apellido;
    if (telefono != null) map['telefono'] = telefono;
    if (roleId != null) map['rol'] = roleId;
    if (codigoEmpleado != null) map['codigo_empleado'] = codigoEmpleado;
    if (activo != null) map['activo'] = activo;
    if (fotoPerfil != null) map['foto_perfil'] = fotoPerfil;

    return map;
  }
}
