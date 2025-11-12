import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/network/auth_interceptor.dart';
import 'package:ss_movil/core/network/dio_client.dart';
import 'package:ss_movil/core/storage/secure_storage.dart';
import 'package:ss_movil/features/accounts/application/state/auth_controller.dart';
import 'package:ss_movil/features/accounts/application/state/auth_state.dart';
import 'package:ss_movil/features/accounts/domain/repositories/auth_repository.dart';
import 'package:ss_movil/features/accounts/infrastructure/datasources/auth_remote_datasource.dart';
import 'package:ss_movil/features/accounts/infrastructure/repositories/auth_repository_impl.dart';
import 'package:ss_movil/features/orders_admin/infrastructure/datasources/orders_remote_datasource.dart';
import 'package:ss_movil/features/orders_admin/infrastructure/repositories/orders_repository_impl.dart';
import 'package:ss_movil/features/orders_admin/domain/repositories/orders_repository.dart';
import 'package:ss_movil/features/reports/data/reports_api.dart';
import 'package:ss_movil/features/reports/data/reports_repository.dart';
import 'package:ss_movil/features/ai/data/ai_api.dart';
import 'package:ss_movil/features/ai/data/ai_repository.dart';

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

// ============================================
// === ORDERS ADMIN PROVIDERS ===
// ============================================

/// Provider de OrdersRemoteDataSource
final ordersRemoteDataSourceProvider = Provider<OrdersRemoteDataSource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return OrdersRemoteDataSourceImpl(dioClient.client);
});

/// Provider de OrdersRepository
final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final dataSource = ref.read(ordersRemoteDataSourceProvider);
  return OrdersRepositoryImpl(dataSource);
});

// ============================================
// === REPORTS PROVIDERS ===
// ============================================

/// Provider de Dio configurado para reportes (timeout extendido)
final reportsDioProvider = Provider<Dio>((ref) {
  final dioClient = ref.read(dioClientProvider);

  // Clonar el cliente existente pero con timeout extendido para reportes
  final reportsDio = Dio(
    BaseOptions(
      baseUrl: dioClient.client.options.baseUrl,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
      sendTimeout: const Duration(seconds: 120),
      headers: dioClient.client.options.headers,
    ),
  );

  // Copiar interceptores existentes (incluyendo AuthInterceptor)
  for (final interceptor in dioClient.client.interceptors) {
    reportsDio.interceptors.add(interceptor);
  }

  return reportsDio;
});

/// Provider de ReportsApi
final reportsApiProvider = Provider<ReportsApi>((ref) {
  final dio = ref.read(reportsDioProvider);
  return ReportsApi(dio, baseUrl: dio.options.baseUrl);
});

/// Provider de ReportsRepository
final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final api = ref.read(reportsApiProvider);
  return ReportsRepository(api);
});

// ============================================
// === AI (INTELIGENCIA ARTIFICIAL) PROVIDERS ===
// ============================================

/// Provider de Dio configurado para IA (timeout extendido 120s)
/// Reutiliza la misma configuración que reportes ya que ambos pueden
/// tener operaciones de larga duración (entrenamiento de modelos, predicciones)
final aiDioProvider = Provider<Dio>((ref) {
  final dioClient = ref.read(dioClientProvider);

  // Crear instancia de Dio con timeout extendido para operaciones de IA
  final aiDio = Dio(
    BaseOptions(
      baseUrl: dioClient.client.options.baseUrl,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
      sendTimeout: const Duration(seconds: 120),
      headers: dioClient.client.options.headers,
    ),
  );

  // Copiar interceptores existentes (incluyendo AuthInterceptor con JWT)
  for (final interceptor in dioClient.client.interceptors) {
    aiDio.interceptors.add(interceptor);
  }

  return aiDio;
});

/// Provider de AiApi
final aiApiProvider = Provider<AiApi>((ref) {
  final dio = ref.read(aiDioProvider);
  return AiApi(dio);
});

/// Provider de AiRepository
final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final api = ref.read(aiApiProvider);
  return AiRepository(api);
});
