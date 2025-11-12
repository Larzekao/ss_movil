import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';

class RefundOrderUseCase {
  final OrdersRepository repository;

  RefundOrderUseCase(this.repository);

  Future<Order> call({required dynamic id, String? reason}) {
    return repository.refundOrder(id: id, reason: reason);
  }
}
