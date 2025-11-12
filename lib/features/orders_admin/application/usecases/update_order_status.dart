import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../domain/value_objects/order_status.dart';

class UpdateOrderStatusUseCase {
  final OrdersRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  Future<Order> call({required dynamic id, required OrderStatus newStatus}) {
    return repository.updateOrderStatus(id: id, newStatus: newStatus);
  }
}
