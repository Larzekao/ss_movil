import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/features/products/domain/entities/brand.dart';
import 'package:ss_movil/features/products/domain/repositories/brands_repository.dart';
import 'package:ss_movil/features/products/application/providers/categories_brands_providers.dart';
import 'package:ss_movil/features/products/application/usecases/brands/list_brands.dart';

/// Estado para la lista de marcas
class BrandsState {
  final List<Brand> brands;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalItems;
  final bool hasMore;

  const BrandsState({
    this.brands = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalItems = 0,
    this.hasMore = true,
  });

  BrandsState copyWith({
    List<Brand>? brands,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalItems,
    bool? hasMore,
  }) {
    return BrandsState(
      brands: brands ?? this.brands,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Provider para gestionar el estado de marcas
class BrandsNotifier extends StateNotifier<BrandsState> {
  final Ref _ref;

  BrandsNotifier(this._ref) : super(const BrandsState());

  /// Carga las marcas con paginación
  Future<void> loadBrands({
    String? search,
    bool? isActive,
    int page = 1,
    bool refresh = false,
  }) async {
    print('🔵 [BrandsNotifier] Iniciando carga de marcas...');
    print('   - page: $page, refresh: $refresh, search: $search');

    if (refresh) {
      state = const BrandsState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final listBrandsUseCase = _ref.read(listBrandsUseCaseProvider);
      final params = ListBrandsParams(
        page: page,
        limit: 20,
        search: search,
        isActive: isActive,
      );

      print('🔵 [BrandsNotifier] Llamando al use case...');
      final result = await listBrandsUseCase(params);

      result.fold(
        (failure) {
          print('❌ [BrandsNotifier] Error: ${failure.message}');
          state = state.copyWith(isLoading: false, error: failure.message);
        },
        (pagedBrands) {
          print('✅ [BrandsNotifier] Marcas cargadas: ${pagedBrands.results.length}');
          print('   - Total en BD: ${pagedBrands.count}');
          state = state.copyWith(
            brands: refresh
                ? pagedBrands.results
                : [...state.brands, ...pagedBrands.results],
            isLoading: false,
            currentPage: page,
            totalItems: pagedBrands.count,
            hasMore: pagedBrands.next != null,
            error: null,
          );
        },
      );
    } catch (e, stackTrace) {
      print('❌ [BrandsNotifier] Excepción: $e');
      print('Stack trace: $stackTrace');
      state = state.copyWith(isLoading: false, error: 'Error: ${e.toString()}');
    }
  }

  /// Crea una nueva marca
  Future<bool> createBrand({
    required String nombre,
    required String descripcion,
    String? logo,
    String? sitioWeb,
    bool activo = true,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final request = CreateBrandRequest(
        nombre: nombre,
        descripcion: descripcion,
        logo: logo,
        sitioWeb: sitioWeb,
      );

      final createBrandUseCase = _ref.read(createBrandUseCaseProvider);
      final result = await createBrandUseCase(request);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: 'Error al crear marca: ${failure.message}',
          );
          return false;
        },
        (brand) async {
          // Recargar la lista
          await loadBrands(refresh: true);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al crear marca: ${e.toString()}',
      );
      return false;
    }
  }

  /// Actualiza una marca existente
  Future<bool> updateBrand({
    required String id,
    required String nombre,
    required String descripcion,
    String? logo,
    String? sitioWeb,
    bool? activo,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final request = UpdateBrandRequest(
        nombre: nombre,
        descripcion: descripcion,
        logo: logo,
        sitioWeb: sitioWeb,
        activo: activo,
      );

      final updateBrandUseCase = _ref.read(updateBrandUseCaseProvider);
      final result = await updateBrandUseCase(id, request);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: 'Error al actualizar marca: ${failure.message}',
          );
          return false;
        },
        (updatedBrand) async {
          await loadBrands(refresh: true);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al actualizar marca: ${e.toString()}',
      );
      return false;
    }
  }

  /// Elimina una marca
  Future<void> deleteBrand(String id) async {
    try {
      final deleteBrandUseCase = _ref.read(deleteBrandUseCaseProvider);
      final result = await deleteBrandUseCase(id);

      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
        },
        (_) {
          final updatedBrands = state.brands.where((b) => b.id != id).toList();
          state = state.copyWith(
            brands: updatedBrands,
            totalItems: state.totalItems - 1,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(error: 'Error: ${e.toString()}');
    }
  }
}

/// Provider para el notificador de marcas
final brandsProvider = StateNotifierProvider<BrandsNotifier, BrandsState>((
  ref,
) {
  return BrandsNotifier(ref);
});
