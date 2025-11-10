import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/entities/product.dart';
import 'package:ss_movil/features/products/domain/repositories/products_repository.dart';

/// Use case para obtener un producto por ID
class GetProduct {
  final ProductsRepository _repository;

  const GetProduct(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, Product>> call(String productId) {
    if (productId.isEmpty) {
      return Future.value(
        const Left(Failure.validation(message: 'ID de producto requerido')),
      );
    }

    return _repository.getProduct(productId);
  }
}
