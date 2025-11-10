import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/entities/brand.dart';
import 'package:ss_movil/features/products/domain/repositories/brands_repository.dart';
import 'package:ss_movil/features/products/infrastructure/datasources/brands_remote_ds.dart';

/// Implementación del BrandsRepository (Infrastructure)
class BrandsRepositoryImpl implements BrandsRepository {
  final BrandsRemoteDataSource _remoteDataSource;

  const BrandsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, PagedBrands>> listBrands({
    int page = 1,
    int limit = 10,
    String? search,
    bool? isActive,
    String? orderBy,
  }) async {
    try {
      print('📦 [BrandsRepo] Llamando al datasource...');
      final pagedDto = await _remoteDataSource.listBrands(
        page: page,
        limit: limit,
        search: search,
        isActive: isActive,
        orderBy: orderBy,
      );

      print('📦 [BrandsRepo] Convirtiendo DTOs a entidades...');
      final brands = pagedDto.results.map((dto) => dto.toEntity()).toList();

      print('📦 [BrandsRepo] Marcas convertidas: ${brands.length}');
      return Right(PagedBrands(
        count: pagedDto.count,
        next: pagedDto.next,
        previous: pagedDto.previous,
        results: brands,
      ));
    } catch (e, stackTrace) {
      print('❌ [BrandsRepo] Error: $e');
      print('Stack trace: $stackTrace');
      return Left(Failure.unknown(message: 'Error al listar marcas: $e'));
    }
  }

  @override
  Future<Either<Failure, Brand>> getBrand(String id) async {
    try {
      final dto = await _remoteDataSource.getBrand(id);
      return Right(dto.toEntity());
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al obtener marca: $e'));
    }
  }

  @override
  Future<Either<Failure, Brand>> createBrand(CreateBrandRequest request) async {
    try {
      final dto = CreateBrandDto(
        nombre: request.nombre,
        descripcion: request.descripcion,
        logo: request.logo,
        sitioWeb: request.sitioWeb,
      );

      final createdDto = await _remoteDataSource.createBrand(dto);
      return Right(createdDto.toEntity());
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al crear marca: $e'));
    }
  }

  @override
  Future<Either<Failure, Brand>> updateBrand(
    String id,
    UpdateBrandRequest request,
  ) async {
    try {
      final dto = UpdateBrandDto(
        nombre: request.nombre,
        descripcion: request.descripcion,
        logo: request.logo,
        sitioWeb: request.sitioWeb,
        activo: request.activo,
      );

      final updatedDto = await _remoteDataSource.updateBrand(id, dto);
      return Right(updatedDto.toEntity());
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al actualizar marca: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBrand(String id) async {
    try {
      await _remoteDataSource.deleteBrand(id);
      return const Right(null);
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al eliminar marca: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Brand>>> getActiveBrands() async {
    try {
      final dtos = await _remoteDataSource.getActiveBrands();
      final brands = dtos.map((dto) => dto.toEntity()).toList();
      return Right(brands);
    } catch (e) {
      return Left(
        Failure.unknown(message: 'Error al obtener marcas activas: $e'),
      );
    }
  }
}
