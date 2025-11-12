import 'package:ss_movil/features/customers/domain/entities/preferencias.dart';

class PreferenciasDto {
  final bool notificaciones;
  final String idioma;
  final String? tallaFavorita;

  PreferenciasDto({
    required this.notificaciones,
    required this.idioma,
    this.tallaFavorita,
  });

  factory PreferenciasDto.fromJson(Map<String, dynamic> json) {
    return PreferenciasDto(
      notificaciones: json['notificaciones'] as bool? ?? true,
      idioma: json['idioma'] as String? ?? 'es',
      tallaFavorita: json['tallaFavorita'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'notificaciones': notificaciones,
    'idioma': idioma,
    'tallaFavorita': tallaFavorita,
  };

  Preferencias toEntity() => Preferencias(
    notificaciones: notificaciones,
    idioma: idioma,
    tallaFavorita: tallaFavorita,
  );

  factory PreferenciasDto.fromEntity(Preferencias entity) {
    return PreferenciasDto(
      notificaciones: entity.notificaciones,
      idioma: entity.idioma,
      tallaFavorita: entity.tallaFavorita,
    );
  }

  @override
  String toString() =>
      'PreferenciasDto(notificaciones: $notificaciones, idioma: $idioma, tallaFavorita: $tallaFavorita)';
}
