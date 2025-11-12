import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/errors/failures.dart';
import '../../application/usecases/get_orders.dart';
import '../../application/usecases/get_order_detail.dart';
import '../../application/usecases/update_order_status.dart';
import '../../application/usecases/refund_order.dart';
import '../../application/usecases/cancel_order.dart';
import '../../domain/entities/order.dart';
import '../../domain/value_objects/order_status.dart';

class OrdersFilter {
  final String? status; // Código del estado: 'pendiente', 'pagado', etc.
  final String? searchQuery; // Campo 'q' en API
  final String? dateFrom; // Fecha inicial
  final String? dateTo; // Fecha final
  final String? sort; // Campo de ordenamiento
  final int page;
  final int pageSize;

  const OrdersFilter({
    this.status,
    this.searchQuery,
    this.dateFrom,
    this.dateTo,
    this.sort,
    this.page = 1,
    this.pageSize = 20,
  });

  OrdersFilter copyWith({
    String? status,
    String? searchQuery,
    String? dateFrom,
    String? dateTo,
    String? sort,
    int? page,
    int? pageSize,
  }) {
    return OrdersFilter(
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      sort: sort ?? this.sort,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  OrdersFilter clearFilters() {
    return const OrdersFilter();
  }
}

class OrdersFilterNotifier extends StateNotifier<OrdersFilter> {
  OrdersFilterNotifier() : super(const OrdersFilter());

  void setStatus(String? status) {
    state = state.copyWith(status: status, page: 1);
  }

  void setSearch(String? query) {
    state = state.copyWith(searchQuery: query, page: 1);
  }

  void setDateRange(String? dateFrom, String? dateTo) {
    state = state.copyWith(dateFrom: dateFrom, dateTo: dateTo, page: 1);
  }

  void setSort(String? sort) {
    state = state.copyWith(sort: sort);
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }

  void reset() {
    state = state.clearFilters();
  }
}

/// Estado para el listado de órdenes
class OrdersState {
  final PaginatedOrders? paginatedOrders;
  final bool hasMore;
  final Failure? error;

  const OrdersState({this.paginatedOrders, this.hasMore = false, this.error});

  OrdersState copyWith({
    PaginatedOrders? paginatedOrders,
    bool? hasMore,
    Failure? error,
  }) {
    return OrdersState(
      paginatedOrders: paginatedOrders ?? this.paginatedOrders,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }

  /// Todos los órdenes cargadas hasta ahora (acumuladas)
  List<Order> get allOrders => paginatedOrders?.data ?? [];

  /// Página actual
  int get currentPage => paginatedOrders?.page ?? 1;

  /// Total de órdenes en la API
  int get total => paginatedOrders?.total ?? 0;
}

/// Notifier para gestionar el listado paginado de órdenes
class OrdersNotifier extends StateNotifier<OrdersState> {
  final GetOrdersUseCase getOrdersUseCase;

  OrdersNotifier(this.getOrdersUseCase) : super(const OrdersState());

  /// Carga la primera página con los filtros aplicados
  Future<void> fetchFirstPage(OrdersFilter filters) async {
    try {
      final result = await getOrdersUseCase(
        page: 1,
        pageSize: filters.pageSize,
        q: filters.searchQuery,
        status: filters.status,
        dateFrom: filters.dateFrom,
        dateTo: filters.dateTo,
        sort: filters.sort,
      );

      final hasMore = result.page < result.totalPages;
      state = OrdersState(
        paginatedOrders: result,
        hasMore: hasMore,
        error: null,
      );
    } on Failure catch (e) {
      state = state.copyWith(error: e);
    } catch (e) {
      state = state.copyWith(error: Failure.unknown(message: e.toString()));
    }
  }

  /// Carga la siguiente página
  Future<void> fetchNextPage(OrdersFilter filters) async {
    if (!state.hasMore || state.paginatedOrders == null) return;

    try {
      final nextPage = state.currentPage + 1;
      final result = await getOrdersUseCase(
        page: nextPage,
        pageSize: filters.pageSize,
        q: filters.searchQuery,
        status: filters.status,
        dateFrom: filters.dateFrom,
        dateTo: filters.dateTo,
        sort: filters.sort,
      );

      // Acumular órdenes de todas las páginas
      final allOrders = [...state.allOrders, ...result.data];
      final combinedPaginatedOrders = PaginatedOrders(
        data: allOrders,
        page: result.page,
        pageSize: result.pageSize,
        total: result.total,
      );

      final hasMore = result.page < result.totalPages;
      state = OrdersState(
        paginatedOrders: combinedPaginatedOrders,
        hasMore: hasMore,
        error: null,
      );
    } on Failure catch (e) {
      state = state.copyWith(error: e);
    } catch (e) {
      state = state.copyWith(error: Failure.unknown(message: e.toString()));
    }
  }

  /// Aplica nuevos filtros (reinicia a página 1)
  Future<void> applyFilters(OrdersFilter filters) async {
    await fetchFirstPage(filters);
  }

  /// Recarga los datos de la página actual
  Future<void> refresh(OrdersFilter filters) async {
    await fetchFirstPage(filters);
  }
}

/// Estado para el detalle de una orden
class OrderDetailState {
  final Order? order;
  final Failure? error;

  const OrderDetailState({this.order, this.error});

  OrderDetailState copyWith({Order? order, Failure? error}) {
    return OrderDetailState(
      order: order ?? this.order,
      error: error ?? this.error,
    );
  }
}

/// Notifier para gestionar el detalle de una orden
class OrderDetailNotifier extends StateNotifier<OrderDetailState> {
  final GetOrderDetailUseCase getOrderDetailUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final RefundOrderUseCase refundOrderUseCase;
  final CancelOrderUseCase cancelOrderUseCase;

  OrderDetailNotifier(
    this.getOrderDetailUseCase,
    this.updateOrderStatusUseCase,
    this.refundOrderUseCase,
    this.cancelOrderUseCase,
  ) : super(const OrderDetailState());

  /// Carga el detalle de una orden
  Future<void> load(dynamic orderId) async {
    try {
      final order = await getOrderDetailUseCase(id: orderId);
      state = OrderDetailState(order: order, error: null);
    } on Failure catch (e) {
      state = state.copyWith(error: e);
    } catch (e) {
      state = state.copyWith(error: Failure.unknown(message: e.toString()));
    }
  }

  /// Actualiza el estado de la orden
  Future<void> updateStatus(OrderStatus newStatus) async {
    if (state.order == null) return;

    try {
      final updatedOrder = await updateOrderStatusUseCase(
        id: state.order!.id,
        newStatus: newStatus,
      );
      state = OrderDetailState(order: updatedOrder, error: null);
    } on Failure catch (e) {
      state = state.copyWith(error: e);
    } catch (e) {
      state = state.copyWith(error: Failure.unknown(message: e.toString()));
    }
  }

  /// Reembolsa la orden
  Future<void> refund({String? reason}) async {
    if (state.order == null) return;

    try {
      final refundedOrder = await refundOrderUseCase(
        id: state.order!.id,
        reason: reason,
      );
      state = OrderDetailState(order: refundedOrder, error: null);
    } on Failure catch (e) {
      state = state.copyWith(error: e);
    } catch (e) {
      state = state.copyWith(error: Failure.unknown(message: e.toString()));
    }
  }

  /// Cancela la orden
  Future<void> cancel({String? reason}) async {
    if (state.order == null) return;

    try {
      final cancelledOrder = await cancelOrderUseCase(
        id: state.order!.id,
        reason: reason,
      );
      state = OrderDetailState(order: cancelledOrder, error: null);
    } on Failure catch (e) {
      state = state.copyWith(error: e);
    } catch (e) {
      state = state.copyWith(error: Failure.unknown(message: e.toString()));
    }
  }
}
