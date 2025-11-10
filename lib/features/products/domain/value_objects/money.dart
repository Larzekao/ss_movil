import 'package:freezed_annotation/freezed_annotation.dart';

part 'money.freezed.dart';

/// Value Object para representar dinero con moneda
@freezed
class Money with _$Money {
  const factory Money({
    required double cantidad,
    @Default('COP') String moneda,
  }) = _Money;

  const Money._();

  /// Crea instancia desde entero (centavos)
  factory Money.fromCentavos(int centavos, {String moneda = 'COP'}) {
    return Money(cantidad: centavos / 100.0, moneda: moneda);
  }

  /// Crea instancia desde string
  factory Money.fromString(String valor, {String moneda = 'COP'}) {
    final cantidad = double.tryParse(valor) ?? 0.0;
    return Money(cantidad: cantidad, moneda: moneda);
  }

  /// Valor en centavos
  int get centavos => (cantidad * 100).round();

  /// Formato de moneda para mostrar
  String get formato {
    switch (moneda) {
      case 'COP':
        return '\$${cantidad.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
      case 'USD':
        return '\$${cantidad.toStringAsFixed(2)}';
      case 'EUR':
        return '€${cantidad.toStringAsFixed(2)}';
      default:
        return '$moneda ${cantidad.toStringAsFixed(2)}';
    }
  }

  /// Suma dos valores de dinero
  Money operator +(Money other) {
    if (moneda != other.moneda) {
      throw ArgumentError('No se pueden sumar monedas diferentes');
    }
    return Money(cantidad: cantidad + other.cantidad, moneda: moneda);
  }

  /// Resta dos valores de dinero
  Money operator -(Money other) {
    if (moneda != other.moneda) {
      throw ArgumentError('No se pueden restar monedas diferentes');
    }
    return Money(cantidad: cantidad - other.cantidad, moneda: moneda);
  }

  /// Multiplica por un factor
  Money operator *(double factor) {
    return Money(cantidad: cantidad * factor, moneda: moneda);
  }

  /// Divide por un factor
  Money operator /(double factor) {
    if (factor == 0) throw ArgumentError('No se puede dividir por cero');
    return Money(cantidad: cantidad / factor, moneda: moneda);
  }

  /// Comparación mayor que
  bool operator >(Money other) {
    if (moneda != other.moneda) {
      throw ArgumentError('No se pueden comparar monedas diferentes');
    }
    return cantidad > other.cantidad;
  }

  /// Comparación menor que
  bool operator <(Money other) {
    if (moneda != other.moneda) {
      throw ArgumentError('No se pueden comparar monedas diferentes');
    }
    return cantidad < other.cantidad;
  }

  /// Verifica si es cero
  bool get esCero => cantidad == 0.0;

  /// Verifica si es positivo
  bool get esPositivo => cantidad > 0.0;

  /// Verifica si es negativo
  bool get esNegativo => cantidad < 0.0;
}
