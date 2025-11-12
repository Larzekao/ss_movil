import 'package:ss_movil/features/customers/domain/entities/direccion.dart';
import 'package:ss_movil/features/customers/domain/repositories/customers_repository.dart';

class UpdateAddressUseCase {
  final CustomersRepository repository;

  UpdateAddressUseCase(this.repository);

  Future<Direccion> call({
    required int id,
    required String etiqueta,
    required String direccionCompleta,
  }) {
    return repository.updateAddress(
      id: id,
      etiqueta: etiqueta,
      direccionCompleta: direccionCompleta,
    );
  }
}
