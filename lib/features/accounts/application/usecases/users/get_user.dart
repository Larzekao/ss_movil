import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/user.dart';
import 'package:ss_movil/features/accounts/domain/repositories/users_repository.dart';

/// Caso de uso para obtener un usuario por ID
class GetUser {
  final UsersRepository repository;

  GetUser(this.repository);

  /// Ejecuta el caso de uso
  ///
  /// [userId] - ID del usuario a obtener
  Future<Either<Failure, User>> call(String userId) {
    return repository.getUser(userId);
  }
}
