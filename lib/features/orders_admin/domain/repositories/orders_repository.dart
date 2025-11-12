import '../entities/order.dart';
import '../value_objects/order_status.dart';

abstract class OrdersRepository {
  /// Obtiene el listado paginado de órdenes con filtros opcionales
  ///
  /// Parámetros:
  /// - page: Número de página (1-based)
  /// - pageSize: Cantidad de registros por página
  /// - q: Término de búsqueda (nombre cliente, código orden, email)
  /// - status: Filtro por estado (código del enum: 'pendiente', 'pagado', 'enviado', 'entregado', 'cancelado', 'reembolsado')
  /// - dateFrom: Fecha inicial de filtro (inclusive)
  /// - dateTo: Fecha final de filtro (inclusive)
  /// - sort: Campo de ordenamiento ('createdAt', '-createdAt', 'totalAmount', '-totalAmount', etc.)
  Future<PaginatedOrders> getOrders({
    required int page,
    required int pageSize,
    String? q,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? sort,
  });

  /// Obtiene el detalle completo de una orden específica
  ///
  /// Parámetros:
  /// - id: ID de la orden (puede ser String o int según backend)
  Future<Order> getOrderDetail({required dynamic id});

  /// Actualiza el estado de una orden
  ///
  /// Parámetros:
  /// - id: ID de la orden
  /// - newStatus: Nuevo estado (OrderStatus value object con código válido)
  Future<Order> updateOrderStatus({
    required dynamic id,
    required OrderStatus newStatus,
  });

  /// Reembolsa una orden completamente
  ///
  /// Parámetros:
  /// - id: ID de la orden
  /// - reason: Razón del reembolso (opcional)
  Future<Order> refundOrder({required dynamic id, String? reason});

  /// Cancela una orden
  ///
  /// Parámetros:
  /// - id: ID de la orden
  /// - reason: Razón de la cancelación (opcional)
  Future<Order> cancelOrder({required dynamic id, String? reason});
}
