import 'package:dio/dio.dart';
import '../dtos/order_dto.dart';
import '../../domain/value_objects/order_status.dart';

abstract class OrdersRemoteDataSource {
  /// Obtiene el listado paginado de órdenes
  Future<PaginatedOrdersDTO> getOrders({
    required int page,
    required int pageSize,
    String? q,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? sort,
  });

  /// Obtiene el detalle de una orden
  Future<OrderDTO> getOrderDetail(dynamic orderId);

  /// Actualiza el estado de una orden
  Future<OrderDTO> updateOrderStatus(dynamic orderId, OrderStatus newStatus);

  /// Reembolsa una orden
  Future<OrderDTO> refundOrder(dynamic orderId, {String? reason});

  /// Cancela una orden
  Future<OrderDTO> cancelOrder(dynamic orderId, {String? reason});
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final Dio dio;

  const OrdersRemoteDataSourceImpl(this.dio);

  @override
  Future<PaginatedOrdersDTO> getOrders({
    required int page,
    required int pageSize,
    String? q,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? sort,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        if (q != null) 'q': q,
        if (status != null) 'status': status,
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
        if (sort != null) 'ordering': sort,
      };

      final response = await dio.get(
        '/orders/pedidos/',
        queryParameters: queryParams,
      );

      // Mapear respuesta DRF: { "results": [...], "count": ..., "next": ..., "previous": ... }
      return PaginatedOrdersDTO.fromJson({
        'data': response.data['results'] ?? [],
        'page': page,
        'pageSize': pageSize,
        'total': response.data['count'] ?? 0,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderDTO> getOrderDetail(dynamic orderId) async {
    try {
      final response = await dio.get('/orders/pedidos/$orderId/');
      return OrderDTO.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderDTO> updateOrderStatus(
    dynamic orderId,
    OrderStatus newStatus,
  ) async {
    try {
      final response = await dio.post(
        '/orders/pedidos/$orderId/cambiar_estado/',
        data: {'nuevo_estado': newStatus.code},
      );
      return OrderDTO.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderDTO> refundOrder(dynamic orderId, {String? reason}) async {
    try {
      final response = await dio.post(
        '/admin/orders/$orderId/refund/',
        data: {if (reason != null) 'reason': reason},
      );
      return OrderDTO.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderDTO> cancelOrder(dynamic orderId, {String? reason}) async {
    try {
      final response = await dio.post(
        '/orders/pedidos/$orderId/cancelar/',
        data: {if (reason != null) 'reason': reason},
      );
      return OrderDTO.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
