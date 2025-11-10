import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/entities/size.dart';
import 'package:ss_movil/features/products/domain/repositories/sizes_repository.dart';
import 'package:ss_movil/features/products/infrastructure/datasources/sizes_remote_ds.dart';

/// Implementación del SizesRepository (Infrastructure)
class SizesRepositoryImpl implements SizesRepository {
  final SizesRemoteDataSource _remoteDataSource;

  const SizesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, PagedSizes>> listSizes({
    int page = 1,
    int limit = 10,
    String? search,
    bool? isActive,
    String? orderBy,
  }) async {
    try {
      final pagedDto = await _remoteDataSource.listSizes(
        page: page,
        limit: limit,
        search: search,
        isActive: isActive,
        orderBy: orderBy,
      );

      final sizes = pagedDto.results.map((dto) => dto.toEntity()).toList();

      return Right(PagedSizes(
        count: pagedDto.count,
        next: pagedDto.next,
        previous: pagedDto.previous,
        results: sizes,
      ));
    } catch (e) {
      return Left(Failure.unknown(message: 'Error al listar tallas: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Size>>> getActiveSizes() async {
    try {
      final dtos = await _remoteDataSource.getActiveSizes();
      final sizes = dtos.map((dto) => dto.toEntity()).toList();
      return Right(sizes);
    } catch (e) {
      return Left(
        Failure.unknown(message: 'Error al obtener tallas activas: $e'),
      );
    }
  }
}
