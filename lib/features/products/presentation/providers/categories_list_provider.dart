import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/features/products/application/providers/categories_brands_providers.dart';
import 'package:ss_movil/features/products/application/usecases/categories/list_categories.dart';
import 'package:ss_movil/features/products/domain/entities/category.dart';
import 'package:ss_movil/core/errors/failures.dart';

/// Estado para la lista de categorías
class CategoriesListState {
  final List<Category> categories;
  final int totalCount;
  final int currentPage;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final String searchQuery;
  final bool? isActiveFilter;

  const CategoriesListState({
    this.categories = const [],
    this.totalCount = 0,
    this.currentPage = 1,
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.searchQuery = '',
    this.isActiveFilter,
  });

  CategoriesListState copyWith({
    List<Category>? categories,
    int? totalCount,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    String? searchQuery,
    bool? isActiveFilter,
  }) {
    return CategoriesListState(
      categories: categories ?? this.categories,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      isActiveFilter: isActiveFilter ?? this.isActiveFilter,
    );
  }
}

/// StateNotifier para gestionar la lista de categorías
class CategoriesListNotifier extends StateNotifier<CategoriesListState> {
  final ListCategories _listCategoriesUseCase;

  CategoriesListNotifier(this._listCategoriesUseCase)
    : super(const CategoriesListState());

  /// Cargar categorías con filtros actuales
  Future<void> loadCategories({bool reset = false}) async {
    if (state.isLoading) return;

    final page = reset ? 1 : state.currentPage;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: page,
      categories: reset ? [] : state.categories,
    );

    final params = ListCategoriesParams(
      page: page,
      limit: 50, // Cargamos más para pickers
      search: state.searchQuery.isEmpty ? null : state.searchQuery,
      isActive: state.isActiveFilter,
    );

    final result = await _listCategoriesUseCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _getFailureMessage(failure),
        );
      },
      (pagedCategories) {
        final newCategories = reset
            ? pagedCategories.results
            : [...state.categories, ...pagedCategories.results];

        state = state.copyWith(
          categories: newCategories,
          totalCount: pagedCategories.count,
          isLoading: false,
          hasMore: pagedCategories.next != null,
          errorMessage: null,
        );
      },
    );
  }

  /// Actualizar búsqueda
  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadCategories(reset: true);
  }

  /// Actualizar filtro de activo
  void updateActiveFilter(bool? isActive) {
    state = state.copyWith(isActiveFilter: isActive);
    loadCategories(reset: true);
  }

  /// Limpiar todos los filtros
  void clearFilters() {
    state = const CategoriesListState();
    loadCategories(reset: true);
  }

  String _getFailureMessage(Failure failure) {
    return failure.when(
      validation: (message, errors) => message,
      auth: (message, statusCode) => message,
      server: (message, statusCode) => message,
      network: (message, statusCode) => message,
      notFound: (message, statusCode) => message,
      unknown: (message) => message,
    );
  }
}

/// Provider para el estado de la lista de categorías
final categoriesListProvider =
    StateNotifierProvider<CategoriesListNotifier, CategoriesListState>((ref) {
      final listCategoriesUseCase = ref.watch(listCategoriesUseCaseProvider);
      return CategoriesListNotifier(listCategoriesUseCase);
    });
