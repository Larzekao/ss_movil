import 'package:ss_movil/features/customers/domain/entities/direccion.dart';

class DireccionDto {
  final int id;
  final String etiqueta;
  final String direccionCompleta;
  final bool esPrincipal;

  DireccionDto({
    required this.id,
    required this.etiqueta,
    required this.direccionCompleta,
    required this.esPrincipal,
  });

  factory DireccionDto.fromJson(Map<String, dynamic> json) {
    return DireccionDto(
      id: json['id'] as int,
      etiqueta: json['etiqueta'] as String,
      direccionCompleta:
          json['direccionCompleta'] as String? ??
          json['direccion'] as String? ??
          '',
      esPrincipal:
          json['esPrincipal'] as bool? ??
          json['es_principal'] as bool? ??
          false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'etiqueta': etiqueta,
    'direccionCompleta': direccionCompleta,
    'esPrincipal': esPrincipal,
  };

  Direccion toEntity() => Direccion(
    id: id,
    etiqueta: etiqueta,
    direccionCompleta: direccionCompleta,
    esPrincipal: esPrincipal,
  );

  factory DireccionDto.fromEntity(Direccion entity) {
    return DireccionDto(
      id: entity.id,
      etiqueta: entity.etiqueta,
      direccionCompleta: entity.direccionCompleta,
      esPrincipal: entity.esPrincipal,
    );
  }

  @override
  String toString() =>
      'DireccionDto(id: $id, etiqueta: $etiqueta, direccionCompleta: $direccionCompleta, esPrincipal: $esPrincipal)';
}
