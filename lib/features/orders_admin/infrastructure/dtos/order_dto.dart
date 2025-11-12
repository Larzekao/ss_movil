import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order.dart';
import '../../domain/value_objects/order_status.dart';

part 'order_dto.g.dart';

/// Convierte un valor a double, maneja strings y números
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

@JsonSerializable()
class OrderTimelineEntryDTO {
  final String action;
  final String description;
  final DateTime timestamp;
  final String? actor;

  OrderTimelineEntryDTO({
    required this.action,
    required this.description,
    required this.timestamp,
    this.actor,
  });

  factory OrderTimelineEntryDTO.fromJson(Map<String, dynamic> json) =>
      _$OrderTimelineEntryDTOFromJson(json);

  Map<String, dynamic> toJson() => _$OrderTimelineEntryDTOToJson(this);

  OrderTimelineEntry toDomain() => OrderTimelineEntry(
    action: action,
    description: description,
    timestamp: timestamp,
    actor: actor,
  );
}

@JsonSerializable()
class OrderDTO {
  final dynamic id; // String | int
  @JsonKey(name: 'numero_pedido')
  final String code;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(defaultValue: 'Cliente')
  final String customerName;
  final String? customerEmail;
  @JsonKey(name: 'total_items')
  final int itemsCount;
  @JsonKey(name: 'total', fromJson: _parseDouble)
  final double totalAmount;
  @JsonKey(defaultValue: 'USD')
  final String currency;
  final String status; // código del estado (ej: 'pendiente', 'pagado', etc.)
  final String? paymentMethod;
  final String? shippingAddress;
  final String? notes;
  final List<OrderTimelineEntryDTO>? timeline;

  OrderDTO({
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

  factory OrderDTO.fromJson(Map<String, dynamic> json) {
    try {
      return OrderDTO(
        id: json['id'] ?? '',
        code: (json['numero_pedido'] ?? json['code'] ?? 'SIN CÓDIGO') as String,
        createdAt:
            DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
            DateTime.now(),
        customerName:
            (json['nombre_cliente'] ?? json['customer_name'] ?? 'Cliente')
                as String,
        customerEmail:
            json['email_cliente']?.toString() ??
            json['customer_email']?.toString(),
        itemsCount: int.tryParse((json['total_items'] ?? 0).toString()) ?? 0,
        totalAmount: _parseDouble(json['total'] ?? json['totalAmount'] ?? 0),
        currency: (json['currency'] ?? 'USD') as String,
        status: (json['estado'] ?? json['status'] ?? 'pendiente') as String,
        paymentMethod:
            json['metodo_pago']?.toString() ??
            json['payment_method']?.toString(),
        shippingAddress:
            json['direccion_envio']?.toString() ??
            json['shipping_address']?.toString(),
        notes: json['notas']?.toString() ?? json['notes']?.toString(),
        timeline: (json['timeline'] as List<dynamic>?)
            ?.map(
              (e) => OrderTimelineEntryDTO.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$OrderDTOToJson(this);

  Order toDomain() => Order(
    id: id,
    code: code,
    createdAt: createdAt,
    updatedAt: updatedAt,
    customerName: customerName,
    customerEmail: customerEmail,
    itemsCount: itemsCount,
    totalAmount: totalAmount,
    currency: currency,
    status: OrderStatus.fromString(status),
    paymentMethod: paymentMethod,
    shippingAddress: shippingAddress,
    notes: notes,
    timeline: timeline?.map((t) => t.toDomain()).toList(),
  );
}

@JsonSerializable()
class PaginatedOrdersDTO {
  final List<OrderDTO> data;
  final int page;
  final int pageSize;
  final int total;

  PaginatedOrdersDTO({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory PaginatedOrdersDTO.fromJson(Map<String, dynamic> json) =>
      _$PaginatedOrdersDTOFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedOrdersDTOToJson(this);

  PaginatedOrders toDomain() => PaginatedOrders(
    data: data.map((dto) => dto.toDomain()).toList(),
    page: page,
    pageSize: pageSize,
    total: total,
  );
}
