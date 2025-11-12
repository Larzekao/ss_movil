import 'package:ss_movil/features/customers/domain/entities/cliente.dart';
import 'package:ss_movil/features/customers/domain/repositories/customers_repository.dart';

class GetMeUseCase {
  final CustomersRepository repository;

  GetMeUseCase(this.repository);

  Future<Cliente> call() {
    return repository.getMe();
  }
}
