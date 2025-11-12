class Direccion {
  final int id;
  final String etiqueta;
  final String direccionCompleta;
  final bool esPrincipal;

  Direccion({
    required this.id,
    required this.etiqueta,
    required this.direccionCompleta,
    required this.esPrincipal,
  });

  @override
  String toString() =>
      'Direccion(id: $id, etiqueta: $etiqueta, direccionCompleta: $direccionCompleta, esPrincipal: $esPrincipal)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Direccion &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          etiqueta == other.etiqueta &&
          direccionCompleta == other.direccionCompleta &&
          esPrincipal == other.esPrincipal;

  @override
  int get hashCode =>
      id.hashCode ^
      etiqueta.hashCode ^
      direccionCompleta.hashCode ^
      esPrincipal.hashCode;
}
