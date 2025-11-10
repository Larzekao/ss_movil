import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/features/products/domain/entities/category.dart';
import 'package:ss_movil/features/products/domain/repositories/categories_repository.dart';
import 'package:ss_movil/features/products/application/providers/categories_brands_providers.dart';
import 'package:ss_movil/features/products/application/usecases/categories/list_categories.dart';
import 'package:ss_movil/features/products/application/usecases/categories/create_category.dart';
import 'package:ss_movil/features/products/application/usecases/categories/update_category.dart';
import 'package:ss_movil/features/products/application/usecases/categories/delete_category.dart';

/// Estado para la lista de categorías
class CategoriesState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalItems;
  final bool hasMore;

  const CategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalItems = 0,
    this.hasMore = true,
  });

  CategoriesState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalItems,
    bool? hasMore,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Provider para gestionar el estado de categorías
class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final ListCategories _listCategoriesUseCase;
  final CreateCategory _createCategoryUseCase;
  final UpdateCategory _updateCategoryUseCase;
  final DeleteCategory _deleteCategoryUseCase;

  CategoriesNotifier(
    this._listCategoriesUseCase,
    this._createCategoryUseCase,
    this._updateCategoryUseCase,
    this._deleteCategoryUseCase,
  ) : super(const CategoriesState());

  /// Carga las categorías con paginación
  Future<void> loadCategories({
    String? search,
    bool? isActive,
    int page = 1,
    bool refresh = false,
  }) async {
    if (refresh) {
      state = const CategoriesState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final params = ListCategoriesParams(
        page: page,
        limit: 20,
        search: search,
        isActive: isActive,
      );

      final result = await _listCategoriesUseCase(params);

      result.fold(
        (failure) {
          state = state.copyWith(isLoading: false, error: failure.message);
        },
        (pagedCategories) {
          state = state.copyWith(
            categories: refresh
                ? pagedCategories.results
                : [...state.categories, ...pagedCategories.results],
            isLoading: false,
            currentPage: page,
            totalItems: pagedCategories.count,
            hasMore: pagedCategories.next != null,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Crea una nueva categoría
  Future<bool> createCategory({
    required String nombre,
    String? descripcion,
    String? imagenPath,
    bool activo = true,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final request = CreateCategoryRequest(
        nombre: nombre,
        descripcion: descripcion,
        imagen: imagenPath,
        orden: 0,
        activa: activo,
      );

      final result = await _createCategoryUseCase(request);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: 'Error al crear categoría: ${failure.message}',
          );
          return false;
        },
        (category) async {
          // Recargar la lista
          await loadCategories(refresh: true);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al crear categoría: ${e.toString()}',
      );
      return false;
    }
  }

  /// Actualiza una categoría existente
  Future<bool> updateCategory({
    required String id,
    String? nombre,
    String? descripcion,
    String? imagenPath,
    bool? activo,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final request = UpdateCategoryRequest(
        nombre: nombre,
        descripcion: descripcion,
        imagen: imagenPath,
        activa: activo,
      );

      final result = await _updateCategoryUseCase(id, request);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: 'Error al actualizar categoría: ${failure.message}',
          );
          return false;
        },
        (category) async {
          // Recargar la lista
          await loadCategories(refresh: true);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al actualizar categoría: ${e.toString()}',
      );
      return false;
    }
  }

  /// Elimina una categoría
  Future<bool> deleteCategory(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _deleteCategoryUseCase(id);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: 'Error al eliminar categoría: ${failure.message}',
          );
          return false;
        },
        (_) {
          // Remover de la lista local
          state = state.copyWith(
            categories: state.categories.where((c) => c.id != id).toList(),
            isLoading: false,
            totalItems: state.totalItems - 1,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al eliminar categoría: ${e.toString()}',
      );
      return false;
    }
  }

  /// Limpia el error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider principal de categorías para la UI
final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
      return CategoriesNotifier(
        ref.read(listCategoriesUseCaseProvider),
        ref.read(createCategoryUseCaseProvider),
        ref.read(updateCategoryUseCaseProvider),
        ref.read(deleteCategoryUseCaseProvider),
      );
    });
