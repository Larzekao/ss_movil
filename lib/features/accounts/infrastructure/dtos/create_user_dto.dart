/// DTO para creación de usuario
///
/// Se envía al backend en POST /api/auth/register/
class CreateUserDto {
  final String email;
  final String password;
  final String passwordConfirm;
  final String nombre;
  final String apellido;
  final String? telefono;
  final String roleId;
  final String? codigoEmpleado;
  final String? fotoPerfil;

  CreateUserDto({
    required this.email,
    required this.password,
    required this.passwordConfirm,
    required this.nombre,
    required this.apellido,
    this.telefono,
    required this.roleId,
    this.codigoEmpleado,
    this.fotoPerfil,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'password_confirm': passwordConfirm,
    'nombre': nombre,
    'apellido': apellido,
    if (telefono != null) 'telefono': telefono,
    'rol': roleId,
    if (codigoEmpleado != null) 'codigo_empleado': codigoEmpleado,
    if (fotoPerfil != null) 'foto_perfil': fotoPerfil,
  };
}
