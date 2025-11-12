import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/features/orders_admin/application/usecases/cancel_order.dart';
import 'package:ss_movil/features/orders_admin/application/usecases/get_order_detail.dart';
import 'package:ss_movil/features/orders_admin/application/usecases/get_orders.dart';
import 'package:ss_movil/features/orders_admin/application/usecases/refund_order.dart';
import 'package:ss_movil/features/orders_admin/application/usecases/update_order_status.dart';
import 'package:ss_movil/features/orders_admin/domain/repositories/orders_repository.dart';
import 'package:ss_movil/features/orders_admin/domain/value_objects/order_status.dart';
import 'package:ss_movil/features/orders_admin/domain/entities/order.dart';
import 'package:ss_movil/features/orders_admin/infrastructure/datasources/orders_remote_datasource.dart';
import 'package:ss_movil/features/orders_admin/infrastructure/repositories/orders_repository_impl.dart';
import 'package:ss_movil/features/orders_admin/presentation/controllers/orders_controller.dart';
import 'package:ss_movil/core/providers/app_providers.dart';

// ============================================================================
// DATASOURCES
// ============================================================================

final ordersRemoteDataSourceProvider = Provider<OrdersRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return OrdersRemoteDataSourceImpl(dioClient.client);
});

// ============================================================================
// REPOSITORIES
// ============================================================================

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final dataSource = ref.watch(ordersRemoteDataSourceProvider);
  return OrdersRepositoryImpl(dataSource);
});

// ============================================================================
// USECASES
// ============================================================================

final getOrdersUseCaseProvider = Provider((ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return GetOrdersUseCase(repository);
});

final getOrderDetailUseCaseProvider = Provider((ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return GetOrderDetailUseCase(repository);
});

final updateOrderStatusUseCaseProvider = Provider((ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return UpdateOrderStatusUseCase(repository);
});

final refundOrderUseCaseProvider = Provider((ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return RefundOrderUseCase(repository);
});

final cancelOrderUseCaseProvider = Provider((ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return CancelOrderUseCase(repository);
});

// ============================================================================
// STATE NOTIFIERS (Controladores)
// ============================================================================

final ordersFilterProvider =
    StateNotifierProvider<OrdersFilterNotifier, OrdersFilter>(
      (ref) => OrdersFilterNotifier(),
    );

/// Controlador para el listado paginado de órdenes
final ordersNotifierProvider =
    StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
      final useCase = ref.watch(getOrdersUseCaseProvider);
      return OrdersNotifier(useCase);
    });

/// Controlador para el detalle de una orden
final orderDetailNotifierProvider =
    StateNotifierProvider<OrderDetailNotifier, OrderDetailState>((ref) {
      final getDetailUseCase = ref.watch(getOrderDetailUseCaseProvider);
      final updateStatusUseCase = ref.watch(updateOrderStatusUseCaseProvider);
      final refundUseCase = ref.watch(refundOrderUseCaseProvider);
      final cancelUseCase = ref.watch(cancelOrderUseCaseProvider);

      return OrderDetailNotifier(
        getDetailUseCase,
        updateStatusUseCase,
        refundUseCase,
        cancelUseCase,
      );
    });

// ============================================================================
// COMPUTED PROVIDERS
// ============================================================================

/// Obtiene el listado paginado de órdenes basado en los filtros actuales
final ordersProvider = FutureProvider.autoDispose<PaginatedOrders>((ref) async {
  final useCase = ref.watch(getOrdersUseCaseProvider);
  final filter = ref.watch(ordersFilterProvider);

  final paginatedOrders = await useCase(
    page: filter.page,
    pageSize: filter.pageSize,
    q: filter.searchQuery,
    status: filter.status,
    dateFrom: filter.dateFrom,
    dateTo: filter.dateTo,
    sort: filter.sort,
  );

  return paginatedOrders;
});

/// Obtiene el detalle de una orden específica por su ID
final orderDetailProvider = FutureProvider.autoDispose.family<Order, String>((
  ref,
  orderId,
) async {
  final useCase = ref.watch(getOrderDetailUseCaseProvider);

  final order = await useCase(id: orderId);

  return order;
});

// ============================================================================
// ACTION PROVIDERS (para ejecutar acciones)
// ============================================================================

/// Actualiza el estado de una orden
final updateOrderStatusProvider = FutureProvider.autoDispose
    .family<Order, (String, OrderStatus)>((ref, params) async {
      final useCase = ref.watch(updateOrderStatusUseCaseProvider);
      final (orderId, newStatus) = params;

      final order = await useCase(id: orderId, newStatus: newStatus);

      // Invalida los listados para refrescarlos
      ref.invalidate(ordersProvider);
      ref.invalidate(orderDetailProvider);

      return order;
    });

/// Reembolsa una orden
final refundOrderProvider = FutureProvider.autoDispose
    .family<Order, (String, String?)>((ref, params) async {
      final useCase = ref.watch(refundOrderUseCaseProvider);
      final (orderId, reason) = params;

      final order = await useCase(id: orderId, reason: reason);

      // Invalida los listados para refrescarlos
      ref.invalidate(ordersProvider);
      ref.invalidate(orderDetailProvider);

      return order;
    });

/// Cancela una orden
final cancelOrderProvider = FutureProvider.autoDispose
    .family<Order, (String, String?)>((ref, params) async {
      final useCase = ref.watch(cancelOrderUseCaseProvider);
      final (orderId, reason) = params;

      final order = await useCase(id: orderId, reason: reason);

      // Invalida los listados para refrescarlos
      ref.invalidate(ordersProvider);
      ref.invalidate(orderDetailProvider);

      return order;
    });
