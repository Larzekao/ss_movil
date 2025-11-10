import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/providers/app_providers.dart';
import 'package:ss_movil/features/products/domain/repositories/products_repository.dart';
import 'package:ss_movil/features/products/infrastructure/datasources/products_remote_ds.dart';
import 'package:ss_movil/features/products/infrastructure/repositories/products_repository_impl.dart';
import 'package:ss_movil/features/products/application/usecases/products/list_products.dart';
import 'package:ss_movil/features/products/application/usecases/products/get_product.dart';
import 'package:ss_movil/features/products/application/usecases/products/create_product.dart';
import 'package:ss_movil/features/products/application/usecases/products/update_product.dart';
import 'package:ss_movil/features/products/application/usecases/products/delete_product.dart';

/// Provider de ProductsRemoteDataSource
final productsRemoteDataSourceProvider = Provider((ref) {
  final dioClient = ref.read(dioClientProvider);
  return ProductsRemoteDataSourceImpl(dioClient.client);
});

/// Provider de ProductsRepository
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final dataSource = ref.read(productsRemoteDataSourceProvider);
  return ProductsRepositoryImpl(dataSource);
});

/// Provider de ListProducts UseCase
final listProductsUseCaseProvider = Provider((ref) {
  final repository = ref.read(productsRepositoryProvider);
  return ListProducts(repository);
});

/// Provider de GetProduct UseCase
final getProductUseCaseProvider = Provider((ref) {
  final repository = ref.read(productsRepositoryProvider);
  return GetProduct(repository);
});

/// Provider de CreateProduct UseCase
final createProductUseCaseProvider = Provider((ref) {
  final repository = ref.read(productsRepositoryProvider);
  return CreateProduct(repository);
});

/// Provider de UpdateProduct UseCase
final updateProductUseCaseProvider = Provider((ref) {
  final repository = ref.read(productsRepositoryProvider);
  return UpdateProduct(repository);
});

/// Provider de DeleteProduct UseCase
final deleteProductUseCaseProvider = Provider((ref) {
  final repository = ref.read(productsRepositoryProvider);
  return DeleteProduct(repository);
});
