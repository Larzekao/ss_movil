import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ss_movil/features/products/domain/entities/size.dart';
import 'package:ss_movil/features/products/domain/entities/stock.dart';
import 'package:ss_movil/features/products/infrastructure/dtos/size_dto.dart';

part 'stock_dto.freezed.dart';

/// DTO para Stock (Infrastructure)
@Freezed(fromJson: false, toJson: false)
class StockDto with _$StockDto {
  const factory StockDto({
    required String id,
    required String tallaId,
    SizeDto? tallaDetalle,
    required int cantidad,
    @Default(5) int stockMinimo,
    @Default('') String createdAt,
    String? updatedAt,
  }) = _StockDto;

  const StockDto._();

  /// Crea DTO desde JSON del backend
  factory StockDto.fromJson(Map<String, dynamic> json) {
    return _StockDto(
      id: json['id'] as String? ?? '',
      tallaId: json['talla'] as String? ?? '',
      tallaDetalle: json['talla_detalle'] != null
          ? SizeDto.fromJson(json['talla_detalle'] as Map<String, dynamic>)
          : null,
      cantidad: json['cantidad'] as int? ?? 0,
      stockMinimo: json['stock_minimo'] as int? ?? 5,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Convierte DTO a entidad del dominio
  Stock toEntity() {
    return Stock(
      id: id,
      tallaId: tallaId,
      tallaDetalle: tallaDetalle?.toEntity() ?? _createDefaultSize(),
      cantidad: cantidad,
      stockMinimo: stockMinimo,
      createdAt: createdAt.isNotEmpty
          ? _parseDateTime(createdAt)
          : DateTime.now(),
      updatedAt: updatedAt != null && updatedAt!.isNotEmpty
          ? _parseDateTime(updatedAt!)
          : null,
    );
  }

  /// Crea una talla por defecto si no existe
  static Size _createDefaultSize() {
    return Size(
      id: '',
      nombre: 'N/A',
      codigo: 'NA',
      orden: 0,
      activo: true,
      createdAt: DateTime.now(),
    );
  }

  /// Parsea DateTime de forma segura manejando diferentes formatos
  static DateTime _parseDateTime(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      final parsed = DateTime.tryParse(dateString);
      if (parsed != null) return parsed;
      return DateTime.now();
    }
  }

  /// Crea DTO desde entidad del dominio
  factory StockDto.fromEntity(Stock entity) {
    return StockDto(
      id: entity.id,
      tallaId: entity.tallaId,
      tallaDetalle: SizeDto.fromEntity(entity.tallaDetalle),
      cantidad: entity.cantidad,
      stockMinimo: entity.stockMinimo,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }

  /// Convierte a JSON para enviar al backend
  Map<String, dynamic> toJson() => {
    'talla': tallaId,
    'cantidad': cantidad,
    'stock_minimo': stockMinimo,
  };
}
