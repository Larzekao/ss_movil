import 'package:ss_movil/features/customers/domain/repositories/customers_repository.dart';

class DeleteAddressUseCase {
  final CustomersRepository repository;

  DeleteAddressUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteAddress(id);
  }
}
