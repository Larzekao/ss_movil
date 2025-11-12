import 'package:ss_movil/features/customers/domain/entities/direccion.dart';
import 'package:ss_movil/features/customers/domain/repositories/customers_repository.dart';

class CreateAddressUseCase {
  final CustomersRepository repository;

  CreateAddressUseCase(this.repository);

  Future<Direccion> call({
    required String etiqueta,
    required String direccionCompleta,
  }) {
    return repository.createAddress(
      etiqueta: etiqueta,
      direccionCompleta: direccionCompleta,
    );
  }
}
