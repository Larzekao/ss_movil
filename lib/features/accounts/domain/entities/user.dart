import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ss_movil/features/accounts/domain/entities/role.dart';

part 'user.freezed.dart';

/// Entidad User (Domain)
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String nombre,
    required String apellido,
    String? telefono,
    String? fotoPerfil,
    required Role rol,
    String? codigoEmpleado,
    @Default(0.0) double saldoBilletera,
    @Default(true) bool activo,
    @Default(false) bool emailVerificado,
    required DateTime createdAt,
  }) = _User;

  const User._();

  /// Nombre completo del usuario
  String get nombreCompleto => '$nombre $apellido';

  /// Verifica si el usuario tiene un permiso específico
  bool tienePermiso(String codigoPermiso) {
    return rol.permisos.any((p) => p.codigo == codigoPermiso);
  }

  /// Verifica si el usuario tiene un rol específico
  bool tieneRol(String nombreRol) {
    return rol.nombre.toLowerCase() == nombreRol.toLowerCase();
  }
}
