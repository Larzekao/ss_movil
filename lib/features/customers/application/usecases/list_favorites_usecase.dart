import 'package:ss_movil/features/customers/domain/repositories/customers_repository.dart';

class ListFavoritesUseCase {
  final CustomersRepository repository;

  ListFavoritesUseCase(this.repository);

  Future<List<int>> call() {
    return repository.listFavorites();
  }
}
