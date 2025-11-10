import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/features/products/application/providers/products_providers.dart';
import 'package:ss_movil/features/products/application/usecases/products/list_products.dart';
import 'package:ss_movil/features/products/domain/entities/product.dart';
import 'package:ss_movil/core/errors/failures.dart';

/// Estado para la lista de productos
class ProductsListState {
  final List<Product> products;
  final int totalCount;
  final int currentPage;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final String searchQuery;
  final String? categoryFilter;
  final String? brandFilter;
  final double? minPriceFilter;
  final double? maxPriceFilter;
  final bool? isActiveFilter;

  const ProductsListState({
    this.products = const [],
    this.totalCount = 0,
    this.currentPage = 1,
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.searchQuery = '',
    this.categoryFilter,
    this.brandFilter,
    this.minPriceFilter,
    this.maxPriceFilter,
    this.isActiveFilter,
  });

  ProductsListState copyWith({
    List<Product>? products,
    int? totalCount,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    String? searchQuery,
    String? categoryFilter,
    String? brandFilter,
    double? minPriceFilter,
    double? maxPriceFilter,
    bool? isActiveFilter,
  }) {
    return ProductsListState(
      products: products ?? this.products,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      brandFilter: brandFilter ?? this.brandFilter,
      minPriceFilter: minPriceFilter ?? this.minPriceFilter,
      maxPriceFilter: maxPriceFilter ?? this.maxPriceFilter,
      isActiveFilter: isActiveFilter ?? this.isActiveFilter,
    );
  }
}

/// StateNotifier para gestionar la lista de productos
class ProductsListNotifier extends StateNotifier<ProductsListState> {
  final ListProducts _listProductsUseCase;

  ProductsListNotifier(this._listProductsUseCase)
    : super(const ProductsListState());

  /// Cargar productos con filtros actuales
  Future<void> loadProducts({bool reset = false}) async {
    if (state.isLoading) return;

    final page = reset ? 1 : state.currentPage;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: page,
      products: reset ? [] : state.products,
    );

    final params = ListProductsParams(
      page: page,
      limit: 20,
      search: state.searchQuery.isEmpty ? null : state.searchQuery,
      categoryId: state.categoryFilter,
      brandId: state.brandFilter,
      minPrice: state.minPriceFilter,
      maxPrice: state.maxPriceFilter,
      isActive: state.isActiveFilter,
    );

    final result = await _listProductsUseCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _getFailureMessage(failure),
        );
      },
      (pagedProducts) {
        final newProducts = reset
            ? pagedProducts.results
            : [...state.products, ...pagedProducts.results];

        state = state.copyWith(
          products: newProducts,
          totalCount: pagedProducts.count,
          isLoading: false,
          hasMore: pagedProducts.next != null,
          errorMessage: null,
        );
      },
    );
  }

  /// Cargar siguiente página
  Future<void> loadNextPage() async {
    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(currentPage: state.currentPage + 1);
    await loadProducts();
  }

  /// Actualizar búsqueda
  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadProducts(reset: true);
  }

  /// Actualizar filtro de categoría
  void updateCategoryFilter(String? categoryId) {
    state = state.copyWith(categoryFilter: categoryId);
    loadProducts(reset: true);
  }

  /// Actualizar filtro de marca
  void updateBrandFilter(String? brandId) {
    state = state.copyWith(brandFilter: brandId);
    loadProducts(reset: true);
  }

  /// Actualizar filtros de precio
  void updatePriceFilters(double? minPrice, double? maxPrice) {
    state = state.copyWith(minPriceFilter: minPrice, maxPriceFilter: maxPrice);
    loadProducts(reset: true);
  }

  /// Actualizar filtro de activo
  void updateActiveFilter(bool? isActive) {
    state = state.copyWith(isActiveFilter: isActive);
    loadProducts(reset: true);
  }

  /// Limpiar todos los filtros
  void clearFilters() {
    state = const ProductsListState();
    loadProducts(reset: true);
  }

  String _getFailureMessage(Failure failure) {
    return failure.when(
      validation: (message, errors) => message,
      auth: (message, statusCode) => message,
      server: (message, statusCode) => message,
      network: (message, statusCode) => message,
      unknown: (message) => message,
    );
  }
}

/// Provider para el estado de la lista de productos
final productsListProvider =
    StateNotifierProvider<ProductsListNotifier, ProductsListState>((ref) {
      final listProductsUseCase = ref.watch(listProductsUseCaseProvider);
      return ProductsListNotifier(listProductsUseCase);
    });
