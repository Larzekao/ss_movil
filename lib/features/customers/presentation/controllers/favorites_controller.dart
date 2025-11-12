import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/exceptions/app_exceptions.dart';
import 'package:ss_movil/core/providers/dio_provider.dart';
import 'package:ss_movil/features/customers/application/usecases/list_favorites_usecase.dart';
import 'package:ss_movil/features/customers/application/usecases/toggle_favorite_usecase.dart';
import 'package:ss_movil/features/customers/domain/repositories/customers_repository.dart';
import 'package:ss_movil/features/customers/infrastructure/datasources/customers_remote_datasource.dart';
import 'package:ss_movil/features/customers/infrastructure/repositories/customers_repository_impl.dart';
import 'package:ss_movil/features/customers/presentation/controllers/favorites_state.dart';

class FavoritesController extends StateNotifier<FavoritesState> {
  final ListFavoritesUseCase listFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final CustomersRepository repository;

  FavoritesController({
    required this.listFavoritesUseCase,
    required this.toggleFavoriteUseCase,
    required this.repository,
  }) : super(FavoritesState());

  /// Carga la lista de IDs de productos favoritos
  Future<void> load() async {
    try {
      state = state.copyWith(loading: true, error: null);
      final ids = await listFavoritesUseCase();
      state = state.copyWith(favoriteIds: ids, loading: false);
    } on AppException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Error desconocido: $e');
    }
  }

  /// Toggle favorito (optimistic update)
  Future<void> toggleFavorite(int productId) async {
    final wasFavorite = state.isFavorite(productId);

    try {
      // Optimistic update: actualiza UI inmediatamente
      if (wasFavorite) {
        state = state.copyWith(
          favoriteIds: state.favoriteIds
              .where((id) => id != productId)
              .toList(),
          error: null,
        );
      } else {
        state = state.copyWith(
          favoriteIds: [...state.favoriteIds, productId],
          error: null,
        );
      }

      // Luego confirma con backend
      await toggleFavoriteUseCase(productId);
    } on AppException catch (e) {
      // Revertir cambios optimistas
      if (wasFavorite) {
        state = state.copyWith(
          favoriteIds: [...state.favoriteIds, productId],
          error: e.message,
        );
      } else {
        state = state.copyWith(
          favoriteIds: state.favoriteIds
              .where((id) => id != productId)
              .toList(),
          error: e.message,
        );
      }
    } catch (e) {
      // Revertir cambios optimistas
      if (wasFavorite) {
        state = state.copyWith(
          favoriteIds: [...state.favoriteIds, productId],
          error: 'Error: $e',
        );
      } else {
        state = state.copyWith(
          favoriteIds: state.favoriteIds
              .where((id) => id != productId)
              .toList(),
          error: 'Error: $e',
        );
      }
    }
  }

  /// Limpia el estado
  void clear() {
    state = FavoritesState();
  }
}

/// Proveedor de Riverpod para ListFavoritesUseCase
final listFavoritesUseCaseProvider = Provider<ListFavoritesUseCase>((ref) {
  final repository = ref.watch(customersRepositoryProvider);
  return ListFavoritesUseCase(repository);
});

/// Proveedor de Riverpod para ToggleFavoriteUseCase
final toggleFavoriteUseCaseProvider = Provider<ToggleFavoriteUseCase>((ref) {
  final repository = ref.watch(customersRepositoryProvider);
  return ToggleFavoriteUseCase(repository);
});

/// Proveedor de Riverpod para CustomersRepository (reutilizable)
final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final remoteDataSource = CustomersRemoteDatasource(dio);
  return CustomersRepositoryImpl(remoteDataSource);
});

/// Proveedor de Riverpod para FavoritesController
final favoritesControllerProvider =
    StateNotifierProvider<FavoritesController, FavoritesState>((ref) {
      final listFavorites = ref.watch(listFavoritesUseCaseProvider);
      final toggleFavorite = ref.watch(toggleFavoriteUseCaseProvider);
      final repository = ref.watch(customersRepositoryProvider);

      return FavoritesController(
        listFavoritesUseCase: listFavorites,
        toggleFavoriteUseCase: toggleFavorite,
        repository: repository,
      );
    });
