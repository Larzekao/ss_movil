import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/entities/category.dart';
import 'package:ss_movil/features/products/domain/repositories/categories_repository.dart';
import 'package:ss_movil/features/products/infrastructure/datasources/categories_remote_ds.dart';

/// Implementación del CategoriesRepository (Infrastructure)
class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource _remoteDataSource;

  const CategoriesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, PagedCategories>> listCategories({
    int page = 1,
    int limit = 10,
    String? search,
    String? parentId,
    bool? isActive,
    String? orderBy,
  }) async {
    try {
      final pagedDto = await _remoteDataSource.listCategories(
        page: page,
        limit: limit,
        search: search,
        parentId: parentId,
        isActive: isActive,
        orderBy: orderBy,
      );

      final categories = pagedDto.results.map((dto) => dto.toEntity()).toList();

      return Right(
        PagedCategories(
          count: pagedDto.count,
          next: pagedDto.next,
          previous: pagedDto.previous,
          results: categories,
        ),
      );
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al listar categorías: $e'));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategory(String id) async {
    try {
      final dto = await _remoteDataSource.getCategory(id);
      return Right(dto.toEntity());
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al obtener categoría: $e'));
    }
  }

  @override
  Future<Either<Failure, Category>> createCategory(
    CreateCategoryRequest request,
  ) async {
    try {
      final dto = CreateCategoryDto(
        nombre: request.nombre,
        descripcion: request.descripcion,
        imagen: request.imagen,
        icono: request.icono,
        color: request.color,
        parentId: request.parentId,
        orden: request.orden,
        activa: request.activa ?? true,
      );

      final createdDto = await _remoteDataSource.createCategory(dto);
      return Right(createdDto.toEntity());
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al crear categoría: $e'));
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory(
    String id,
    UpdateCategoryRequest request,
  ) async {
    try {
      final dto = UpdateCategoryDto(
        nombre: request.nombre,
        descripcion: request.descripcion,
        imagen: request.imagen,
        icono: request.icono,
        color: request.color,
        parentId: request.parentId,
        orden: request.orden,
        activa: request.activa,
      );

      final updatedDto = await _remoteDataSource.updateCategory(id, dto);
      return Right(updatedDto.toEntity());
    } catch (e) {
      return Left(
        Failure.unknown(message: 'Error al actualizar categoría: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await _remoteDataSource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al eliminar categoría: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getRootCategories() async {
    try {
      // TODO: Implementar llamada al dataSource y conversión de DTOs
      // final dtos = await _remoteDataSource.getRootCategories();
      // final categories = dtos.map((dto) => dto.toEntity()).toList();
      // return Right(categories);

      throw UnimplementedError('TODO: Implementar getRootCategories');
    } catch (e) {
      return const Left(
        Failure.unknown(message: 'Error al obtener categorías raíz'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getSubcategories(
    String parentId,
  ) async {
    try {
      // TODO: Implementar llamada al dataSource y conversión de DTOs
      // final dtos = await _remoteDataSource.getSubcategories(parentId);
      // final categories = dtos.map((dto) => dto.toEntity()).toList();
      // return Right(categories);

      throw UnimplementedError('TODO: Implementar getSubcategories');
    } catch (e) {
      return const Left(
        Failure.unknown(message: 'Error al obtener subcategorías'),
      );
    }
  }
}
