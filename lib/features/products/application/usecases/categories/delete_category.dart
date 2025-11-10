import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/repositories/categories_repository.dart';

/// Use case para eliminar una categoría
class DeleteCategory {
  final CategoriesRepository _repository;

  const DeleteCategory(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, void>> call(String categoryId) {
    if (categoryId.isEmpty) {
      return Future.value(
        const Left(Failure.validation(message: 'ID de categoría requerido')),
      );
    }

    return _repository.deleteCategory(categoryId);
  }
}
