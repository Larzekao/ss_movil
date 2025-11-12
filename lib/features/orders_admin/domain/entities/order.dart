import '../value_objects/order_status.dart';

class OrderTimelineEntry {
  final String action;
  final String description;
  final DateTime timestamp;
  final String? actor;

  const OrderTimelineEntry({
    required this.action,
    required this.description,
    required this.timestamp,
    this.actor,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderTimelineEntry &&
          runtimeType == other.runtimeType &&
          action == other.action &&
          description == other.description &&
          timestamp == other.timestamp &&
          actor == other.actor;

  @override
  int get hashCode => Object.hash(action, description, timestamp, actor);

  @override
  String toString() =>
      'OrderTimelineEntry(action: $action, timestamp: $timestamp, actor: $actor)';
}

class Order {
  final dynamic id; // String | int
  final String code;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String customerName;
  final String? customerEmail;
  final int itemsCount;
  final double totalAmount;
  final String currency;
  final OrderStatus status;
  final String? paymentMethod;
  final String? shippingAddress;
  final String? notes;
  final List<OrderTimelineEntry>? timeline;

  const Order({
    required this.id,
    required this.code,
    required this.createdAt,
    required this.updatedAt,
    required this.customerName,
    this.customerEmail,
    required this.itemsCount,
    required this.totalAmount,
    required this.currency,
    required this.status,
    this.paymentMethod,
    this.shippingAddress,
    this.notes,
    this.timeline,
  });

  // Status helper properties
  bool get isPendiente => status.value == OrderStatusEnum.pendiente;
  bool get isPagado => status.value == OrderStatusEnum.pagoRecibido;
  bool get isEnviado => status.value == OrderStatusEnum.enviado;
  bool get isEntregado => status.value == OrderStatusEnum.entregado;
  bool get isCancelado => status.value == OrderStatusEnum.cancelado;
  bool get isReembolsado => status.value == OrderStatusEnum.reembolsado;

  // Can this order be cancelled?
  bool get canBeCancelled => isPendiente || isPagado;

  // Can this order be refunded?
  bool get canBeRefunded => isPagado || isEnviado;

  Order copyWith({
    dynamic id,
    String? code,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerName,
    String? customerEmail,
    int? itemsCount,
    double? totalAmount,
    String? currency,
    OrderStatus? status,
    String? paymentMethod,
    String? shippingAddress,
    String? notes,
    List<OrderTimelineEntry>? timeline,
  }) {
    return Order(
      id: id ?? this.id,
      code: code ?? this.code,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      itemsCount: itemsCount ?? this.itemsCount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      notes: notes ?? this.notes,
      timeline: timeline ?? this.timeline,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          customerName == other.customerName &&
          customerEmail == other.customerEmail &&
          itemsCount == other.itemsCount &&
          totalAmount == other.totalAmount &&
          currency == other.currency &&
          status == other.status &&
          paymentMethod == other.paymentMethod &&
          shippingAddress == other.shippingAddress &&
          notes == other.notes &&
          timeline == other.timeline;

  @override
  int get hashCode => Object.hashAll([
    id,
    code,
    createdAt,
    updatedAt,
    customerName,
    customerEmail,
    itemsCount,
    totalAmount,
    currency,
    status,
    paymentMethod,
    shippingAddress,
    notes,
    timeline,
  ]);

  @override
  String toString() => 'Order(id: $id, code: $code, status: ${status.label})';
}

class PaginatedOrders {
  final List<Order> data;
  final int page;
  final int pageSize;
  final int total;

  const PaginatedOrders({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  bool get hasMore => (page * pageSize) < total;
  int get totalPages => (total / pageSize).ceil();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginatedOrders &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          page == other.page &&
          pageSize == other.pageSize &&
          total == other.total;

  @override
  int get hashCode => Object.hash(data, page, pageSize, total);

  @override
  String toString() =>
      'PaginatedOrders(page: $page, total: $total, items: ${data.length})';
}
