import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/repositories/categories_repository.dart';

/// Use case para listar categorías paginadas
class ListCategories {
  final CategoriesRepository _repository;

  const ListCategories(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, PagedCategories>> call(ListCategoriesParams params) {
    return _repository.listCategories(
      page: params.page,
      limit: params.limit,
      search: params.search,
      parentId: params.parentId,
      isActive: params.isActive,
      orderBy: params.orderBy,
    );
  }
}

/// Parámetros para listar categorías
class ListCategoriesParams {
  final int page;
  final int limit;
  final String? search;
  final String? parentId;
  final bool? isActive;
  final String? orderBy;

  const ListCategoriesParams({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.parentId,
    this.isActive,
    this.orderBy,
  });

  /// Copia con nuevos parámetros
  ListCategoriesParams copyWith({
    int? page,
    int? limit,
    String? search,
    String? parentId,
    bool? isActive,
    String? orderBy,
  }) {
    return ListCategoriesParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      parentId: parentId ?? this.parentId,
      isActive: isActive ?? this.isActive,
      orderBy: orderBy ?? this.orderBy,
    );
  }
}
