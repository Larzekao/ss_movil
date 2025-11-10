import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/repositories/sizes_repository.dart';

/// Use case para listar tallas paginadas
class ListSizes {
  final SizesRepository _repository;

  const ListSizes(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, PagedSizes>> call(ListSizesParams params) {
    return _repository.listSizes(
      page: params.page,
      limit: params.limit,
      search: params.search,
      isActive: params.isActive,
      orderBy: params.orderBy,
    );
  }
}

/// Parámetros para listar tallas
class ListSizesParams {
  final int page;
  final int limit;
  final String? search;
  final bool? isActive;
  final String? orderBy;

  const ListSizesParams({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.isActive,
    this.orderBy,
  });

  /// Copia con nuevos parámetros
  ListSizesParams copyWith({
    int? page,
    int? limit,
    String? search,
    bool? isActive,
    String? orderBy,
  }) {
    return ListSizesParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      isActive: isActive ?? this.isActive,
      orderBy: orderBy ?? this.orderBy,
    );
  }
}
