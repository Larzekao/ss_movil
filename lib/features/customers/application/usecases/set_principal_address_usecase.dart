import 'package:ss_movil/features/customers/domain/entities/direccion.dart';
import 'package:ss_movil/features/customers/domain/repositories/customers_repository.dart';

class SetPrincipalAddressUseCase {
  final CustomersRepository repository;

  SetPrincipalAddressUseCase(this.repository);

  Future<Direccion> call(int id) {
    return repository.setPrincipal(id);
  }
}
