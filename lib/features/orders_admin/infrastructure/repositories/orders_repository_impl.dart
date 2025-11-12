import 'package:dio/dio.dart';
import 'package:ss_movil/core/errors/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../domain/value_objects/order_status.dart';
import '../datasources/orders_remote_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  const OrdersRepositoryImpl(this.remoteDataSource);

  /// Convierte excepciones de Dio a Failures
  Failure _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.response?.statusCode) {
        case 401:
          return Failure.auth(
            message: error.response?.data?['detail'] ?? 'No autorizado',
            statusCode: 401,
          );
        case 404:
          return Failure.notFound(
            message: error.response?.data?['detail'] ?? 'Recurso no encontrado',
            statusCode: 404,
          );
        case 400:
        case 422:
          return Failure.validation(
            message: error.response?.data?['detail'] ?? 'Error de validación',
            errors: _parseValidationErrors(error.response?.data),
          );
        case 500:
        case 502:
        case 503:
          return Failure.server(
            message: error.response?.data?['detail'] ?? 'Error del servidor',
            statusCode: error.response?.statusCode,
          );
        default:
          return Failure.network(
            message: error.message ?? 'Error de conexión',
            statusCode: error.response?.statusCode,
          );
      }
    }
    return Failure.unknown(message: error.toString());
  }

  /// Parsea errores de validación del endpoint DRF
  Map<String, List<String>>? _parseValidationErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final errors = <String, List<String>>{};
    data.forEach((key, value) {
      if (value is List) {
        errors[key] = List<String>.from(value.map((v) => v.toString()));
      } else if (value is String) {
        errors[key] = [value];
      }
    });

    return errors.isEmpty ? null : errors;
  }

  @override
  Future<PaginatedOrders> getOrders({
    required int page,
    required int pageSize,
    String? q,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? sort,
  }) async {
    try {
      final dto = await remoteDataSource.getOrders(
        page: page,
        pageSize: pageSize,
        q: q,
        status: status,
        dateFrom: dateFrom,
        dateTo: dateTo,
        sort: sort,
      );
      return dto.toDomain();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Order> getOrderDetail({required dynamic id}) async {
    try {
      final dto = await remoteDataSource.getOrderDetail(id);
      return dto.toDomain();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Order> updateOrderStatus({
    required dynamic id,
    required OrderStatus newStatus,
  }) async {
    try {
      final dto = await remoteDataSource.updateOrderStatus(id, newStatus);
      return dto.toDomain();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Order> refundOrder({required dynamic id, String? reason}) async {
    try {
      final dto = await remoteDataSource.refundOrder(id, reason: reason);
      return dto.toDomain();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Order> cancelOrder({required dynamic id, String? reason}) async {
    try {
      final dto = await remoteDataSource.cancelOrder(id, reason: reason);
      return dto.toDomain();
    } catch (e) {
      throw _handleError(e);
    }
  }
}
