import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';

class GetOrdersUseCase {
  final OrdersRepository repository;

  GetOrdersUseCase(this.repository);

  Future<PaginatedOrders> call({
    required int page,
    required int pageSize,
    String? q,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? sort,
  }) {
    return repository.getOrders(
      page: page,
      pageSize: pageSize,
      q: q,
      status: status,
      dateFrom: dateFrom,
      dateTo: dateTo,
      sort: sort,
    );
  }
}
