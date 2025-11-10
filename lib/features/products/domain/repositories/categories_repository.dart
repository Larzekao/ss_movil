import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/entities/category.dart';

/// Repository contract para Categories (Domain)
abstract class CategoriesRepository {
  /// Lista categorías paginadas con filtros opcionales
  Future<Either<Failure, PagedCategories>> listCategories({
    int page = 1,
    int limit = 10,
    String? search,
    String? parentId,
    bool? isActive,
    String? orderBy,
  });

  /// Obtiene una categoría por ID
  Future<Either<Failure, Category>> getCategory(String id);

  /// Crea una nueva categoría
  Future<Either<Failure, Category>> createCategory(
    CreateCategoryRequest request,
  );

  /// Actualiza una categoría existente
  Future<Either<Failure, Category>> updateCategory(
    String id,
    UpdateCategoryRequest request,
  );

  /// Elimina una categoría
  Future<Either<Failure, void>> deleteCategory(String id);

  /// Lista categorías principales (sin padre)
  Future<Either<Failure, List<Category>>> getRootCategories();

  /// Lista subcategorías de una categoría padre
  Future<Either<Failure, List<Category>>> getSubcategories(String parentId);
}

/// Resultado paginado de categorías
class PagedCategories {
  final int count;
  final String? next;
  final String? previous;
  final List<Category> results;

  const PagedCategories({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });
}

/// Request para crear categoría
class CreateCategoryRequest {
  final String nombre;
  final String? descripcion;
  final String? imagen;
  final String? icono;
  final String? color;
  final String? parentId;
  final int orden;
  final bool? activa;

  const CreateCategoryRequest({
    required this.nombre,
    this.descripcion,
    this.imagen,
    this.icono,
    this.color,
    this.parentId,
    this.orden = 0,
    this.activa,
  });
}

/// Request para actualizar categoría
class UpdateCategoryRequest {
  final String? nombre;
  final String? descripcion;
  final String? imagen;
  final String? icono;
  final String? color;
  final String? parentId;
  final int? orden;
  final bool? activa;

  const UpdateCategoryRequest({
    this.nombre,
    this.descripcion,
    this.imagen,
    this.icono,
    this.color,
    this.parentId,
    this.orden,
    this.activa,
  });
}
