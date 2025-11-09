import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/user.dart';
import 'package:ss_movil/features/accounts/domain/repositories/users_repository.dart';

/// Caso de uso para crear un nuevo usuario
class CreateUser {
  final UsersRepository repository;

  CreateUser(this.repository);

  /// Ejecuta el caso de uso
  ///
  /// [email] - Email del usuario (único)
  /// [password] - Contraseña
  /// [passwordConfirm] - Confirmación de contraseña
  /// [nombre] - Nombre
  /// [apellido] - Apellido
  /// [telefono] - Teléfono (opcional)
  /// [roleId] - ID del rol a asignar
  /// [codigoEmpleado] - Código de empleado (opcional)
  /// [fotoPerfil] - Foto de perfil en base64 (opcional)
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String passwordConfirm,
    required String nombre,
    required String apellido,
    String? telefono,
    required String roleId,
    String? codigoEmpleado,
    String? fotoPerfil,
  }) {
    return repository.createUser(
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
      nombre: nombre,
      apellido: apellido,
      telefono: telefono,
      roleId: roleId,
      codigoEmpleado: codigoEmpleado,
      fotoPerfil: fotoPerfil,
    );
  }
}
