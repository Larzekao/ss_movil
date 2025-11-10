import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/entities/category.dart';
import 'package:ss_movil/features/products/domain/repositories/categories_repository.dart';

/// Use case para actualizar una categoría existente
class UpdateCategory {
  final CategoriesRepository _repository;

  const UpdateCategory(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, Category>> call(
    String categoryId,
    UpdateCategoryRequest request,
  ) {
    if (categoryId.isEmpty) {
      return Future.value(
        const Left(Failure.validation(message: 'ID de categoría requerido')),
      );
    }

    // Validaciones condicionales
    if (request.nombre != null && request.nombre!.isEmpty) {
      return Future.value(
        const Left(Failure.validation(message: 'Nombre no puede estar vacío')),
      );
    }

    if (request.orden != null && request.orden! < 0) {
      return Future.value(
        const Left(Failure.validation(message: 'Orden no puede ser negativo')),
      );
    }

    return _repository.updateCategory(categoryId, request);
  }
}
