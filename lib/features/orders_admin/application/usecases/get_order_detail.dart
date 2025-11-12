import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';

class GetOrderDetailUseCase {
  final OrdersRepository repository;

  GetOrderDetailUseCase(this.repository);

  Future<Order> call({required dynamic id}) {
    return repository.getOrderDetail(id: id);
  }
}
