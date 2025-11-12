class Preferencias {
  final bool notificaciones;
  final String idioma;
  final String? tallaFavorita;

  Preferencias({
    required this.notificaciones,
    required this.idioma,
    this.tallaFavorita,
  });

  @override
  String toString() =>
      'Preferencias(notificaciones: $notificaciones, idioma: $idioma, tallaFavorita: $tallaFavorita)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Preferencias &&
          runtimeType == other.runtimeType &&
          notificaciones == other.notificaciones &&
          idioma == other.idioma &&
          tallaFavorita == other.tallaFavorita;

  @override
  int get hashCode =>
      notificaciones.hashCode ^ idioma.hashCode ^ tallaFavorita.hashCode;
}
