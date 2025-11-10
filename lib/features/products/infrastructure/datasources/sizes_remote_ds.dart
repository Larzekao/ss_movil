import 'package:ss_movil/features/products/infrastructure/dtos/size_dto.dart';
import 'package:ss_movil/features/products/infrastructure/dtos/paged_dto.dart';

/// Remote DataSource para Sizes/Tallas (Infrastructure) - SOLO FIRMAS
abstract class SizesRemoteDataSource {
  /// Lista tallas paginadas con filtros opcionales
  Future<PagedDto<SizeDto>> listSizes({
    int page = 1,
    int limit = 10,
    String? search,
    bool? isActive,
    String? orderBy,
  });

  /// Lista todas las tallas activas (sin paginación)
  Future<List<SizeDto>> getActiveSizes();
}
