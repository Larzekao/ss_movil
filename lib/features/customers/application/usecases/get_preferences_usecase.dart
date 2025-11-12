import 'package:ss_movil/features/customers/domain/entities/preferencias.dart';
import 'package:ss_movil/features/customers/domain/repositories/customers_repository.dart';

class GetPreferencesUseCase {
  final CustomersRepository repository;

  GetPreferencesUseCase(this.repository);

  Future<Preferencias> call() {
    return repository.getPreferences();
  }
}
