import 'package:ss_movil/features/customers/domain/entities/cliente.dart';

class ClienteDto {
  final int id;
  final String email;
  final String? nombre;
  final String? telefono;

  ClienteDto({
    required this.id,
    required this.email,
    this.nombre,
    this.telefono,
  });

  factory ClienteDto.fromJson(Map<String, dynamic> json) {
    return ClienteDto(
      id: json['id'] as int,
      email: json['email'] as String,
      nombre: json['nombre'] as String?,
      telefono: json['telefono'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'nombre': nombre,
    'telefono': telefono,
  };

  Cliente toEntity() =>
      Cliente(id: id, email: email, nombre: nombre, telefono: telefono);

  factory ClienteDto.fromEntity(Cliente entity) {
    return ClienteDto(
      id: entity.id,
      email: entity.email,
      nombre: entity.nombre,
      telefono: entity.telefono,
    );
  }

  @override
  String toString() =>
      'ClienteDto(id: $id, email: $email, nombre: $nombre, telefono: $telefono)';
}
