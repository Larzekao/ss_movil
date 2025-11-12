import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/providers/app_providers.dart';
import 'package:ss_movil/features/products/domain/repositories/categories_repository.dart';
import 'package:ss_movil/features/products/domain/repositories/brands_repository.dart';
import 'package:ss_movil/features/products/domain/repositories/sizes_repository.dart';
import 'package:ss_movil/features/products/infrastructure/datasources/categories_remote_ds.dart';
import 'package:ss_movil/features/products/infrastructure/datasources/brands_remote_ds.dart';
import 'package:ss_movil/features/products/infrastructure/datasources/brands_remote_ds_impl.dart';
import 'package:ss_movil/features/products/infrastructure/datasources/sizes_remote_ds.dart';
import 'package:ss_movil/features/products/infrastructure/datasources/sizes_remote_ds_impl.dart';
import 'package:ss_movil/features/products/infrastructure/repositories/categories_repository_impl.dart';
import 'package:ss_movil/features/products/infrastructure/repositories/brands_repository_impl.dart';
import 'package:ss_movil/features/products/infrastructure/repositories/sizes_repository_impl.dart';
import 'package:ss_movil/features/products/application/usecases/categories/list_categories.dart';
import 'package:ss_movil/features/products/application/usecases/categories/create_category.dart';
import 'package:ss_movil/features/products/application/usecases/categories/update_category.dart';
import 'package:ss_movil/features/products/application/usecases/categories/delete_category.dart';
import 'package:ss_movil/features/products/application/usecases/brands/list_brands.dart';
import 'package:ss_movil/features/products/application/usecases/brands/create_brand.dart';
import 'package:ss_movil/features/products/application/usecases/brands/update_brand.dart';
import 'package:ss_movil/features/products/application/usecases/brands/delete_brand.dart';
import 'package:ss_movil/features/products/application/usecases/sizes/list_sizes.dart';

// === PROVIDERS DE CATEGORÍAS ===

/// Provider de CategoriesRemoteDataSource
final categoriesRemoteDataSourceProvider = Provider<CategoriesRemoteDataSource>(
  (ref) {
    final dioClient = ref.read(dioClientProvider);
    return CategoriesRemoteDataSourceImpl(dioClient.client);
  },
);

/// Provider de CategoriesRepository
final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final dataSource = ref.read(categoriesRemoteDataSourceProvider);
  return CategoriesRepositoryImpl(dataSource);
});

/// Provider de ListCategories UseCase
final listCategoriesUseCaseProvider = Provider((ref) {
  final repository = ref.read(categoriesRepositoryProvider);
  return ListCategories(repository);
});

/// Provider de CreateCategory UseCase
final createCategoryUseCaseProvider = Provider((ref) {
  final repository = ref.read(categoriesRepositoryProvider);
  return CreateCategory(repository);
});

/// Provider de UpdateCategory UseCase
final updateCategoryUseCaseProvider = Provider((ref) {
  final repository = ref.read(categoriesRepositoryProvider);
  return UpdateCategory(repository);
});

/// Provider de DeleteCategory UseCase
final deleteCategoryUseCaseProvider = Provider((ref) {
  final repository = ref.read(categoriesRepositoryProvider);
  return DeleteCategory(repository);
});

// === PROVIDERS DE MARCAS ===

/// Provider de BrandsRemoteDataSource
final brandsRemoteDataSourceProvider = Provider<BrandsRemoteDataSource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return BrandsRemoteDataSourceImpl(dioClient.client);
});

/// Provider de BrandsRepository
final brandsRepositoryProvider = Provider<BrandsRepository>((ref) {
  final dataSource = ref.read(brandsRemoteDataSourceProvider);
  return BrandsRepositoryImpl(dataSource);
});

/// Provider de ListBrands UseCase
final listBrandsUseCaseProvider = Provider((ref) {
  final repository = ref.read(brandsRepositoryProvider);
  return ListBrands(repository);
});

/// Provider de CreateBrand UseCase
final createBrandUseCaseProvider = Provider((ref) {
  final repository = ref.read(brandsRepositoryProvider);
  return CreateBrand(repository);
});

/// Provider de UpdateBrand UseCase
final updateBrandUseCaseProvider = Provider((ref) {
  final repository = ref.read(brandsRepositoryProvider);
  return UpdateBrand(repository);
});

/// Provider de DeleteBrand UseCase
final deleteBrandUseCaseProvider = Provider((ref) {
  final repository = ref.read(brandsRepositoryProvider);
  return DeleteBrand(repository);
});

// === PROVIDERS DE TALLAS ===

/// Provider de SizesRemoteDataSource
final sizesRemoteDataSourceProvider = Provider<SizesRemoteDataSource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return SizesRemoteDataSourceImpl(dioClient.client);
});

/// Provider de SizesRepository
final sizesRepositoryProvider = Provider<SizesRepository>((ref) {
  final dataSource = ref.read(sizesRemoteDataSourceProvider);
  return SizesRepositoryImpl(dataSource);
});

/// Provider de ListSizes UseCase
final listSizesUseCaseProvider = Provider((ref) {
  final repository = ref.read(sizesRepositoryProvider);
  return ListSizes(repository);
});
