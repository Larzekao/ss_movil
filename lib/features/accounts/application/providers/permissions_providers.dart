import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/providers/app_providers.dart';
import 'package:ss_movil/features/accounts/application/usecases/permissions/list_permissions.dart';
import 'package:ss_movil/features/accounts/domain/entities/permission.dart';
import 'package:ss_movil/features/accounts/domain/repositories/permissions_repository.dart';
import 'package:ss_movil/features/accounts/infrastructure/datasources/permissions_remote_datasource.dart';
import 'package:ss_movil/features/accounts/infrastructure/repositories/permissions_repository_impl.dart';

/// Provider de PermissionsRemoteDataSource
final permissionsRemoteDataSourceProvider = Provider((ref) {
  final dioClient = ref.read(dioClientProvider);
  return PermissionsRemoteDataSource(dioClient.client);
});

/// Provider de PermissionsRepository
final permissionsRepositoryProvider = Provider<PermissionsRepository>((ref) {
  final dataSource = ref.read(permissionsRemoteDataSourceProvider);
  return PermissionsRepositoryImpl(remoteDataSource: dataSource);
});

// ============================================================================
// USE CASES PROVIDERS
// ============================================================================

/// Provider del caso de uso ListPermissions
final listPermissionsUseCaseProvider = Provider((ref) {
  final repository = ref.read(permissionsRepositoryProvider);
  return ListPermissions(repository);
});

// ============================================================================
// STATE PROVIDERS
// ============================================================================

/// State de búsqueda de permisos
final permissionsSearchProvider = StateProvider<String>((ref) => '');

/// Provider para obtener la lista de permisos
final permissionsProvider = FutureProvider<List<Permission>>((ref) async {
  final useCase = ref.read(listPermissionsUseCaseProvider);
  final search = ref.watch(permissionsSearchProvider);

  final result = await useCase.call(search: search.isNotEmpty ? search : null);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (permissions) => permissions,
  );
});

/// Provider para obtener permisos agrupados por módulo
final permissionsGroupedProvider =
    FutureProvider<Map<String, List<Permission>>>((ref) async {
      final permissions = await ref.watch(permissionsProvider.future);
      final searchTerm = ref.watch(permissionsSearchProvider).toLowerCase();

      // Filtrar según término de búsqueda
      List<Permission> filtered = permissions;
      if (searchTerm.isNotEmpty) {
        filtered = permissions.where((p) {
          return p.modulo.toLowerCase().contains(searchTerm) ||
              p.codigo.toLowerCase().contains(searchTerm);
        }).toList();
      }

      // Agrupar por módulo
      final grouped = <String, List<Permission>>{};
      for (final permission in filtered) {
        final module = permission.modulo;
        if (!grouped.containsKey(module)) {
          grouped[module] = [];
        }
        grouped[module]!.add(permission);
      }

      return grouped;
    });
