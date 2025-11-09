import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/network/auth_interceptor.dart';
import 'package:ss_movil/core/network/dio_client.dart';
import 'package:ss_movil/core/storage/secure_storage.dart';
import 'package:ss_movil/features/accounts/application/state/auth_controller.dart';
import 'package:ss_movil/features/accounts/application/state/auth_state.dart';
import 'package:ss_movil/features/accounts/domain/repositories/auth_repository.dart';
import 'package:ss_movil/features/accounts/infrastructure/datasources/auth_remote_datasource.dart';
import 'package:ss_movil/features/accounts/infrastructure/repositories/auth_repository_impl.dart';

/// Provider de SecureStorage (singleton)
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// Provider de DioClient (singleton con AuthInterceptor)
final dioClientProvider = Provider((ref) {
  final dioClient = DioClient();
  final storage = ref.read(secureStorageProvider);

  // Añadir AuthInterceptor
  final authInterceptor = AuthInterceptor(dioClient.client, storage);
  dioClient.addInterceptor(authInterceptor);

  return dioClient;
});

/// Provider de AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider((ref) {
  final dioClient = ref.read(dioClientProvider);
  return AuthRemoteDataSource(dioClient.client);
});

/// Provider de AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.read(authRemoteDataSourceProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthRepositoryImpl(dataSource, storage);
});

/// Provider de AuthController (StateNotifier)
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final repository = ref.read(authRepositoryProvider);
    final storage = ref.read(secureStorageProvider);
    return AuthController(repository, storage);
  },
);
