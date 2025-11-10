import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/repositories/brands_repository.dart';

/// Use case para listar marcas paginadas
class ListBrands {
  final BrandsRepository _repository;

  const ListBrands(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, PagedBrands>> call(ListBrandsParams params) {
    return _repository.listBrands(
      page: params.page,
      limit: params.limit,
      search: params.search,
      isActive: params.isActive,
      orderBy: params.orderBy,
    );
  }
}

/// Parámetros para listar marcas
class ListBrandsParams {
  final int page;
  final int limit;
  final String? search;
  final bool? isActive;
  final String? orderBy;

  const ListBrandsParams({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.isActive,
    this.orderBy,
  });

  /// Copia con nuevos parámetros
  ListBrandsParams copyWith({
    int? page,
    int? limit,
    String? search,
    bool? isActive,
    String? orderBy,
  }) {
    return ListBrandsParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      isActive: isActive ?? this.isActive,
      orderBy: orderBy ?? this.orderBy,
    );
  }
}
