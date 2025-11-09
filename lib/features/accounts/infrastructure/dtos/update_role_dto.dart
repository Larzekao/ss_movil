/// DTO para actualizar un rol existente
///
/// Se envía al backend en PATCH /api/auth/roles/{id}/
class UpdateRoleDto {
  final String? nombre;
  final String? descripcion;
  final List<String>? permisosIds;

  UpdateRoleDto({this.nombre, this.descripcion, this.permisosIds});

  Map<String, dynamic> toJson() => {
    if (nombre != null) 'nombre': nombre,
    if (descripcion != null) 'descripcion': descripcion,
    if (permisosIds != null) 'permisos_ids': permisosIds,
  };
}
