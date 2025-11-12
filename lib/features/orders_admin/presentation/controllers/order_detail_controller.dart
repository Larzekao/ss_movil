import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/errors/failures.dart';
import '../../application/usecases/get_order_detail.dart';
import '../../application/usecases/update_order_status.dart';
import '../../application/usecases/refund_order.dart';
import '../../application/usecases/cancel_order.dart';
import '../../domain/entities/order.dart';
import '../../domain/value_objects/order_status.dart';

class OrderDetailState {
  final Order? order;
  final bool isLoading;
  final Failure? error;
  final bool isUpdatingStatus;
  final bool isRefunding;
  final bool isCancelling;

  const OrderDetailState({
    this.order,
    this.isLoading = false,
    this.error,
    this.isUpdatingStatus = false,
    this.isRefunding = false,
    this.isCancelling = false,
  });

  OrderDetailState copyWith({
    Order? order,
    bool? isLoading,
    Failure? error,
    bool? isUpdatingStatus,
    bool? isRefunding,
    bool? isCancelling,
  }) {
    return OrderDetailState(
      order: order ?? this.order,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
      isRefunding: isRefunding ?? this.isRefunding,
      isCancelling: isCancelling ?? this.isCancelling,
    );
  }
}

class OrderDetailNotifier extends StateNotifier<OrderDetailState> {
  final GetOrderDetailUseCase _getDetailUseCase;
  final UpdateOrderStatusUseCase _updateStatusUseCase;
  final RefundOrderUseCase _refundUseCase;
  final CancelOrderUseCase _cancelUseCase;

  OrderDetailNotifier(
    this._getDetailUseCase,
    this._updateStatusUseCase,
    this._refundUseCase,
    this._cancelUseCase,
  ) : super(const OrderDetailState());

  /// Carga el detalle de la orden
  Future<void> load(dynamic orderId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final order = await _getDetailUseCase(id: orderId);
      state = state.copyWith(order: order, isLoading: false);
    } on Failure catch (e) {
      state = state.copyWith(error: e, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: Failure.unknown(message: e.toString()),
        isLoading: false,
      );
    }
  }

  /// Actualiza el estado de la orden
  Future<void> updateStatus(OrderStatus newStatus) async {
    if (state.order == null) return;

    state = state.copyWith(isUpdatingStatus: true, error: null);
    try {
      final updatedOrder = await _updateStatusUseCase(
        id: state.order!.id,
        newStatus: newStatus,
      );
      state = state.copyWith(order: updatedOrder, isUpdatingStatus: false);
    } on Failure catch (e) {
      state = state.copyWith(error: e, isUpdatingStatus: false);
    } catch (e) {
      state = state.copyWith(
        error: Failure.unknown(message: e.toString()),
        isUpdatingStatus: false,
      );
    }
  }

  /// Reembolsa la orden
  Future<void> refund({String? reason}) async {
    if (state.order == null) return;

    state = state.copyWith(isRefunding: true, error: null);
    try {
      final updatedOrder = await _refundUseCase(
        id: state.order!.id,
        reason: reason,
      );
      state = state.copyWith(order: updatedOrder, isRefunding: false);
    } on Failure catch (e) {
      state = state.copyWith(error: e, isRefunding: false);
    } catch (e) {
      state = state.copyWith(
        error: Failure.unknown(message: e.toString()),
        isRefunding: false,
      );
    }
  }

  /// Cancela la orden
  Future<void> cancel({String? reason}) async {
    if (state.order == null) return;

    state = state.copyWith(isCancelling: true, error: null);
    try {
      final updatedOrder = await _cancelUseCase(
        id: state.order!.id,
        reason: reason,
      );
      state = state.copyWith(order: updatedOrder, isCancelling: false);
    } on Failure catch (e) {
      state = state.copyWith(error: e, isCancelling: false);
    } catch (e) {
      state = state.copyWith(
        error: Failure.unknown(message: e.toString()),
        isCancelling: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
