import 'package:ss_movil/features/customers/domain/repositories/customers_repository.dart';

class ToggleFavoriteUseCase {
  final CustomersRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<void> call(int productId) {
    return repository.toggleFavorite(productId);
  }
}
