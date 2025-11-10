import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/entities/category.dart';
import 'package:ss_movil/features/products/domain/repositories/categories_repository.dart';

/// Use case para crear una nueva categoría
class CreateCategory {
  final CategoriesRepository _repository;

  const CreateCategory(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, Category>> call(CreateCategoryRequest request) {
    // Validaciones básicas
    if (request.nombre.isEmpty) {
      return Future.value(
        const Left(
          Failure.validation(message: 'Nombre de la categoría requerido'),
        ),
      );
    }

    if (request.orden < 0) {
      return Future.value(
        const Left(Failure.validation(message: 'Orden no puede ser negativo')),
      );
    }

    return _repository.createCategory(request);
  }
}
