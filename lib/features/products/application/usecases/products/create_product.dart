import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/entities/product.dart';
import 'package:ss_movil/features/products/domain/repositories/products_repository.dart';

/// Use case para crear un nuevo producto
class CreateProduct {
  final ProductsRepository _repository;

  const CreateProduct(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, Product>> call(CreateProductRequest request) {
    // Validaciones básicas
    if (request.nombre.isEmpty) {
      return Future.value(
        const Left(
          Failure.validation(message: 'Nombre del producto requerido'),
        ),
      );
    }

    if (request.precio <= 0) {
      return Future.value(
        const Left(Failure.validation(message: 'Precio debe ser mayor a cero')),
      );
    }

    if (request.stock < 0) {
      return Future.value(
        const Left(Failure.validation(message: 'Stock no puede ser negativo')),
      );
    }

    if (request.codigo.isEmpty) {
      return Future.value(
        const Left(
          Failure.validation(message: 'Código del producto requerido'),
        ),
      );
    }

    return _repository.createProduct(request);
  }
}
