import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/features/products/application/providers/categories_brands_providers.dart';
import 'package:ss_movil/features/products/application/usecases/brands/list_brands.dart';
import 'package:ss_movil/features/products/domain/entities/brand.dart';
import 'package:ss_movil/core/errors/failures.dart';

/// Estado para la lista de marcas
class BrandsListState {
  final List<Brand> brands;
  final int totalCount;
  final int currentPage;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final String searchQuery;
  final bool? isActiveFilter;

  const BrandsListState({
    this.brands = const [],
    this.totalCount = 0,
    this.currentPage = 1,
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.searchQuery = '',
    this.isActiveFilter,
  });

  BrandsListState copyWith({
    List<Brand>? brands,
    int? totalCount,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    String? searchQuery,
    bool? isActiveFilter,
  }) {
    return BrandsListState(
      brands: brands ?? this.brands,
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

/// StateNotifier para gestionar la lista de marcas
class BrandsListNotifier extends StateNotifier<BrandsListState> {
  final ListBrands _listBrandsUseCase;

  BrandsListNotifier(this._listBrandsUseCase) : super(const BrandsListState());

  /// Cargar marcas con filtros actuales
  Future<void> loadBrands({bool reset = false}) async {
    if (state.isLoading) return;

    final page = reset ? 1 : state.currentPage;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: page,
      brands: reset ? [] : state.brands,
    );

    final params = ListBrandsParams(
      page: page,
      limit: 50, // Cargamos más para pickers
      search: state.searchQuery.isEmpty ? null : state.searchQuery,
      isActive: state.isActiveFilter,
    );

    final result = await _listBrandsUseCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _getFailureMessage(failure),
        );
      },
      (pagedBrands) {
        final newBrands = reset
            ? pagedBrands.results
            : [...state.brands, ...pagedBrands.results];

        state = state.copyWith(
          brands: newBrands,
          totalCount: pagedBrands.count,
          isLoading: false,
          hasMore: pagedBrands.next != null,
          errorMessage: null,
        );
      },
    );
  }

  /// Actualizar búsqueda
  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadBrands(reset: true);
  }

  /// Actualizar filtro de activo
  void updateActiveFilter(bool? isActive) {
    state = state.copyWith(isActiveFilter: isActive);
    loadBrands(reset: true);
  }

  /// Limpiar todos los filtros
  void clearFilters() {
    state = const BrandsListState();
    loadBrands(reset: true);
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

/// Provider para el estado de la lista de marcas
final brandsListProvider =
    StateNotifierProvider<BrandsListNotifier, BrandsListState>((ref) {
      final listBrandsUseCase = ref.watch(listBrandsUseCaseProvider);
      return BrandsListNotifier(listBrandsUseCase);
    });
