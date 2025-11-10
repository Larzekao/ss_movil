import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/repositories/brands_repository.dart';

/// Use case para eliminar una marca
class DeleteBrand {
  final BrandsRepository _repository;

  const DeleteBrand(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, void>> call(String brandId) {
    if (brandId.isEmpty) {
      return Future.value(
        const Left(Failure.validation(message: 'ID de marca requerido')),
      );
    }

    return _repository.deleteBrand(brandId);
  }
}
