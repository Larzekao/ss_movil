import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/entities/product.dart';
import 'package:ss_movil/features/products/domain/repositories/products_repository.dart';

/// Use case para actualizar un producto existente
class UpdateProduct {
  final ProductsRepository _repository;

  const UpdateProduct(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, Product>> call(
    String productId,
    UpdateProductRequest request,
  ) {
    if (productId.isEmpty) {
      return Future.value(
        const Left(Failure.validation(message: 'ID de producto requerido')),
      );
    }

    // Validaciones condicionales
    if (request.precio != null && request.precio! <= 0) {
      return Future.value(
        const Left(Failure.validation(message: 'Precio debe ser mayor a cero')),
      );
    }

    if (request.stock != null && request.stock! < 0) {
      return Future.value(
        const Left(Failure.validation(message: 'Stock no puede ser negativo')),
      );
    }

    if (request.nombre != null && request.nombre!.isEmpty) {
      return Future.value(
        const Left(Failure.validation(message: 'Nombre no puede estar vacío')),
      );
    }

    if (request.codigo != null && request.codigo!.isEmpty) {
      return Future.value(
        const Left(Failure.validation(message: 'Código no puede estar vacío')),
      );
    }

    return _repository.updateProduct(productId, request);
  }
}
