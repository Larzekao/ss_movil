/// DTO para crear un nuevo rol
///
/// Se envía al backend en POST /api/auth/roles/
class CreateRoleDto {
  final String nombre;
  final String? descripcion;
  final List<String> permisosIds;

  CreateRoleDto({
    required this.nombre,
    this.descripcion,
    required this.permisosIds,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    if (descripcion != null) 'descripcion': descripcion,
    'permisos_ids': permisosIds,
  };
}
