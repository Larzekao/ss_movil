import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/providers/app_providers.dart';
import 'package:ss_movil/features/accounts/infrastructure/datasources/permissions_remote_datasource.dart';
import 'package:ss_movil/features/accounts/domain/entities/permission.dart';

/// Remote datasource para permisos
final permissionsRemoteDataSourceProvider = Provider((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PermissionsRemoteDataSource(dioClient.client);
});

/// Provider que obtiene la lista de permisos disponibles
final permissionsListProvider = FutureProvider.autoDispose<List<Permission>>((
  ref,
) async {
  final remoteDataSource = ref.watch(permissionsRemoteDataSourceProvider);
  final permissionDtos = await remoteDataSource.getPermissions();
  return permissionDtos.map((dto) => dto.toEntity()).toList();
});
