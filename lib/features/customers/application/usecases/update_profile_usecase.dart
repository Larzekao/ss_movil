import 'package:ss_movil/features/customers/domain/entities/cliente.dart';
import 'package:ss_movil/features/customers/domain/repositories/customers_repository.dart';

class UpdateProfileUseCase {
  final CustomersRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Cliente> call({String? nombre, String? telefono}) {
    return repository.updateProfile(nombre: nombre, telefono: telefono);
  }
}
