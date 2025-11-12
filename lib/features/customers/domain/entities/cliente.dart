class Cliente {
  final int id;
  final String email;
  final String? nombre;
  final String? telefono;

  Cliente({required this.id, required this.email, this.nombre, this.telefono});

  @override
  String toString() =>
      'Cliente(id: $id, email: $email, nombre: $nombre, telefono: $telefono)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cliente &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          nombre == other.nombre &&
          telefono == other.telefono;

  @override
  int get hashCode =>
      id.hashCode ^ email.hashCode ^ nombre.hashCode ^ telefono.hashCode;
}
