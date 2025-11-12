import 'package:ss_movil/features/customers/domain/entities/preferencias.dart';
import 'package:ss_movil/features/customers/domain/repositories/customers_repository.dart';

class UpdatePreferencesUseCase {
  final CustomersRepository repository;

  UpdatePreferencesUseCase(this.repository);

  Future<Preferencias> call({
    bool? notificaciones,
    String? idioma,
    String? tallaFavorita,
  }) {
    return repository.updatePreferences(
      notificaciones: notificaciones,
      idioma: idioma,
      tallaFavorita: tallaFavorita,
    );
  }
}
