import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/entities/size.dart';

/// Repository contract para Sizes/Tallas (Domain)
abstract class SizesRepository {
  /// Lista tallas paginadas con filtros opcionales
  Future<Either<Failure, PagedSizes>> listSizes({
    int page = 1,
    int limit = 10,
    String? search,
    bool? isActive,
    String? orderBy,
  });

  /// Lista todas las tallas activas (sin paginación)
  Future<Either<Failure, List<Size>>> getActiveSizes();
}

/// Resultado paginado de tallas
class PagedSizes {
  final int count;
  final String? next;
  final String? previous;
  final List<Size> results;

  const PagedSizes({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });
}
