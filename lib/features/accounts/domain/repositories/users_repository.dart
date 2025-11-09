import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/accounts/domain/entities/user.dart';

/// Repositorio abstracto para gestión de usuarios (CRUD)
///
/// Define la interfaz para operaciones de usuarios sin especificar
/// la implementación (puede ser API REST, GraphQL, local, etc.)
abstract class UsersRepository {
  /// Lista usuarios con paginación, búsqueda y filtros
  ///
  /// [page] - Número de página (empezando en 1)
  /// [pageSize] - Cantidad de usuarios por página
  /// [search] - Término de búsqueda (nombre, email)
  /// [roleId] - Filtrar por ID de rol
  /// [isActive] - Filtrar por estado activo/inactivo
  ///
  /// Returns: `Either<Failure, PagedUsers>`
  Future<Either<Failure, PagedUsers>> listUsers({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? roleId,
    bool? isActive,
  });

  /// Obtiene un usuario específico por ID
  ///
  /// [userId] - ID del usuario
  ///
  /// Returns: `Either<Failure, User>`
  Future<Either<Failure, User>> getUser(String userId);

  /// Crea un nuevo usuario
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
  ///
  /// Returns: `Either<Failure, User>`
  Future<Either<Failure, User>> createUser({
    required String email,
    required String password,
    required String passwordConfirm,
    required String nombre,
    required String apellido,
    String? telefono,
    required String roleId,
    String? codigoEmpleado,
    String? fotoPerfil,
  });

  /// Actualiza un usuario existente
  ///
  /// [userId] - ID del usuario a actualizar
  /// Los demás parámetros son opcionales (solo se actualizan los proporcionados)
  ///
  /// Returns: `Either<Failure, User>`
  Future<Either<Failure, User>> updateUser({
    required String userId,
    String? email,
    String? password,
    String? nombre,
    String? apellido,
    String? telefono,
    String? roleId,
    String? codigoEmpleado,
    String? fotoPerfil,
  });

  /// Activa o desactiva un usuario (soft delete)
  ///
  /// [userId] - ID del usuario
  /// [isActive] - true para activar, false para desactivar
  ///
  /// Returns: `Either<Failure, User>`
  Future<Either<Failure, User>> toggleActiveUser({
    required String userId,
    required bool isActive,
  });

  /// Elimina un usuario (hard delete)
  ///
  /// [userId] - ID del usuario a eliminar
  ///
  /// Returns: `Either<Failure, void>`
  Future<Either<Failure, void>> deleteUser(String userId);
}

/// Clase para respuesta paginada de usuarios
class PagedUsers {
  final int count;
  final String? next;
  final String? previous;
  final List<User> results;

  PagedUsers({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  /// Indica si hay más páginas disponibles
  bool get hasNext => next != null;

  /// Indica si hay páginas anteriores
  bool get hasPrevious => previous != null;

  /// Número total de páginas (aproximado)
  int get totalPages => (count / results.length).ceil();
}
