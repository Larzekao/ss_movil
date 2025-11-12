import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';

class CancelOrderUseCase {
  final OrdersRepository repository;

  CancelOrderUseCase(this.repository);

  Future<Order> call({required dynamic id, String? reason}) {
    return repository.cancelOrder(id: id, reason: reason);
  }
}
