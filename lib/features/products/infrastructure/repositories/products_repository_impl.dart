import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/entities/product.dart';
import 'package:ss_movil/features/products/domain/repositories/products_repository.dart';
import 'package:ss_movil/features/products/infrastructure/datasources/products_remote_ds.dart';
import 'package:ss_movil/features/products/infrastructure/dtos/product_dto.dart';

/// Implementación del ProductsRepository (Infrastructure)
class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource _remoteDataSource;

  const ProductsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, PagedProducts>> listProducts({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    String? brandId,
    double? minPrice,
    double? maxPrice,
    bool? isActive,
    String? orderBy,
  }) async {
    try {
      final pagedDto = await _remoteDataSource.listProducts(
        page: page,
        limit: limit,
        search: search,
        categoryId: categoryId,
        brandId: brandId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        isActive: isActive,
        orderBy: orderBy,
      );

      final products = pagedDto.results.map((dto) => dto.toEntity()).toList();

      return Right(
        PagedProducts(
          count: pagedDto.count,
          next: pagedDto.next,
          previous: pagedDto.previous,
          results: products,
        ),
      );
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message));
    } on NotFoundException catch (e) {
      return Left(Failure.validation(message: e.message));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al listar productos: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProduct(String id) async {
    try {
      final dto = await _remoteDataSource.getProduct(id);
      return Right(dto.toEntity());
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message));
    } on NotFoundException catch (e) {
      return Left(Failure.validation(message: e.message));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al obtener producto: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct(
    CreateProductRequest request,
  ) async {
    try {
      final dto = CreateProductDto(
        nombre: request.nombre,
        descripcion: request.descripcion,
        precio: request.precio.toStringAsFixed(2),
        stock: request.stock,
        codigo: request.codigo,
        categoryId: request.categoryId,
        brandId: request.brandId,
        sizeIds: request.sizeIds,
        material: request.material,
        genero: request.genero,
        temporada: request.temporada,
        color: request.color,
        imagenPath: request.imagenPath,
      );

      final createdDto = await _remoteDataSource.createProduct(dto);
      return Right(createdDto.toEntity());
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message));
    } on NotFoundException catch (e) {
      return Left(Failure.validation(message: e.message));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al crear producto: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(
    String id,
    UpdateProductRequest request,
  ) async {
    try {
      final dto = UpdateProductDto(
        nombre: request.nombre,
        descripcion: request.descripcion,
        precio: request.precio?.toString(),
        material: request.material,
        color: request.color,
        activa: request.activo,
      );

      final updatedDto = await _remoteDataSource.updateProduct(id, dto);
      return Right(updatedDto.toEntity());
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message));
    } on NotFoundException catch (e) {
      return Left(Failure.validation(message: e.message));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al actualizar producto: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await _remoteDataSource.deleteProduct(id);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(Failure.auth(message: e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message));
    } on NotFoundException catch (e) {
      return Left(Failure.validation(message: e.message));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al eliminar producto: $e'));
    }
  }
}
