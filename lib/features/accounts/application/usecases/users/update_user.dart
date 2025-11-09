import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/user.dart';
import 'package:ss_movil/features/accounts/domain/repositories/users_repository.dart';

/// Caso de uso para actualizar un usuario existente
class UpdateUser {
  final UsersRepository repository;

  UpdateUser(this.repository);

  /// Ejecuta el caso de uso
  ///
  /// [userId] - ID del usuario a actualizar
  /// Los demás parámetros son opcionales (solo se actualizan los proporcionados)
  Future<Either<Failure, User>> call({
    required String userId,
    String? email,
    String? password,
    String? nombre,
    String? apellido,
    String? telefono,
    String? roleId,
    String? codigoEmpleado,
    String? fotoPerfil,
  }) {
    return repository.updateUser(
      userId: userId,
      email: email,
      password: password,
      nombre: nombre,
      apellido: apellido,
      telefono: telefono,
      roleId: roleId,
      codigoEmpleado: codigoEmpleado,
      fotoPerfil: fotoPerfil,
    );
  }
}
