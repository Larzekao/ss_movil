import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/repositories/products_repository.dart';

/// Use case para eliminar un producto
class DeleteProduct {
  final ProductsRepository _repository;

  const DeleteProduct(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, void>> call(String productId) {
    if (productId.isEmpty) {
      return Future.value(
        const Left(Failure.validation(message: 'ID de producto requerido')),
      );
    }

    return _repository.deleteProduct(productId);
  }
}
