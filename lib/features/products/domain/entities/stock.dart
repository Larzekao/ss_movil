import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ss_movil/features/products/domain/entities/size.dart';

part 'stock.freezed.dart';

/// Entidad Stock (Domain)
/// Representa el stock de una prenda por talla
@freezed
class Stock with _$Stock {
  const factory Stock({
    required String id,
    required String tallaId,
    required Size tallaDetalle,
    required int cantidad,
    @Default(5) int stockMinimo,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Stock;

  const Stock._();

  /// Verifica si hay alerta de stock bajo
  bool get alertaStockBajo => cantidad <= stockMinimo;

  /// Verifica si hay stock disponible
  bool get tieneStock => cantidad > 0;
}
