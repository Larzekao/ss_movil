import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/repositories/products_repository.dart';

/// Use case para listar productos paginados
class ListProducts {
  final ProductsRepository _repository;

  const ListProducts(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, PagedProducts>> call(ListProductsParams params) {
    return _repository.listProducts(
      page: params.page,
      limit: params.limit,
      search: params.search,
      categoryId: params.categoryId,
      brandId: params.brandId,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      isActive: params.isActive,
      orderBy: params.orderBy,
    );
  }
}

/// Parámetros para listar productos
class ListProductsParams {
  final int page;
  final int limit;
  final String? search;
  final String? categoryId;
  final String? brandId;
  final double? minPrice;
  final double? maxPrice;
  final bool? isActive;
  final String? orderBy;

  const ListProductsParams({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.categoryId,
    this.brandId,
    this.minPrice,
    this.maxPrice,
    this.isActive,
    this.orderBy,
  });

  /// Copia con nuevos parámetros
  ListProductsParams copyWith({
    int? page,
    int? limit,
    String? search,
    String? categoryId,
    String? brandId,
    double? minPrice,
    double? maxPrice,
    bool? isActive,
    String? orderBy,
  }) {
    return ListProductsParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      isActive: isActive ?? this.isActive,
      orderBy: orderBy ?? this.orderBy,
    );
  }
}
