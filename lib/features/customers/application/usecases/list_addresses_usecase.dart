import 'package:ss_movil/features/customers/domain/entities/direccion.dart';
import 'package:ss_movil/features/customers/domain/repositories/customers_repository.dart';

class ListAddressesUseCase {
  final CustomersRepository repository;

  ListAddressesUseCase(this.repository);

  Future<List<Direccion>> call() {
    return repository.listAddresses();
  }
}
