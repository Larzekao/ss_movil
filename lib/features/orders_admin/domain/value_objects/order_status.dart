enum OrderStatusEnum {
  pendiente,
  pagoRecibido, // pago_recibido
  preparando, // preparando
  confirmado, // confirmado
  enviado,
  entregado,
  cancelado,
  reembolsado,
}

extension OrderStatusExtension on OrderStatusEnum {
  String get code {
    switch (this) {
      case OrderStatusEnum.pendiente:
        return 'pendiente';
      case OrderStatusEnum.pagoRecibido:
        return 'pago_recibido';
      case OrderStatusEnum.preparando:
        return 'preparando';
      case OrderStatusEnum.confirmado:
        return 'confirmado';
      case OrderStatusEnum.enviado:
        return 'enviado';
      case OrderStatusEnum.entregado:
        return 'entregado';
      case OrderStatusEnum.cancelado:
        return 'cancelado';
      case OrderStatusEnum.reembolsado:
        return 'reembolsado';
    }
  }

  String get label {
    switch (this) {
      case OrderStatusEnum.pendiente:
        return 'Pendiente';
      case OrderStatusEnum.pagoRecibido:
        return 'Pago Recibido';
      case OrderStatusEnum.preparando:
        return 'Preparando';
      case OrderStatusEnum.confirmado:
        return 'Confirmado';
      case OrderStatusEnum.enviado:
        return 'Enviado';
      case OrderStatusEnum.entregado:
        return 'Entregado';
      case OrderStatusEnum.cancelado:
        return 'Cancelado';
      case OrderStatusEnum.reembolsado:
        return 'Reembolsado';
    }
  }

  int get order {
    switch (this) {
      case OrderStatusEnum.pendiente:
        return 0;
      case OrderStatusEnum.pagoRecibido:
        return 1;
      case OrderStatusEnum.preparando:
        return 2;
      case OrderStatusEnum.confirmado:
        return 3;
      case OrderStatusEnum.enviado:
        return 4;
      case OrderStatusEnum.entregado:
        return 5;
      case OrderStatusEnum.cancelado:
        return 6;
      case OrderStatusEnum.reembolsado:
        return 7;
    }
  }
}

class OrderStatus {
  final OrderStatusEnum value;

  const OrderStatus(this.value);

  factory OrderStatus.fromCode(String code) {
    return OrderStatus(
      OrderStatusEnum.values.firstWhere(
        (e) => e.code == code,
        orElse: () => OrderStatusEnum.pendiente,
      ),
    );
  }

  /// Alias para fromCode para mantener compatibilidad
  factory OrderStatus.fromString(String code) {
    return OrderStatus.fromCode(code);
  }

  String get code => value.code;
  String get label => value.label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderStatus &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'OrderStatus($label)';
}
