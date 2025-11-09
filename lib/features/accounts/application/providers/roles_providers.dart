import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/providers/app_providers.dart';
import 'package:ss_movil/features/accounts/application/usecases/roles/list_roles.dart';
import 'package:ss_movil/features/accounts/application/usecases/roles/get_role.dart';
import 'package:ss_movil/features/accounts/application/usecases/roles/create_role.dart';
import 'package:ss_movil/features/accounts/application/usecases/roles/update_role.dart';
import 'package:ss_movil/features/accounts/application/usecases/roles/delete_role.dart';
import 'package:ss_movil/features/accounts/domain/entities/role.dart';
import 'package:ss_movil/features/accounts/domain/repositories/roles_repository.dart';
import 'package:ss_movil/features/accounts/infrastructure/datasources/roles_remote_datasource.dart';
import 'package:ss_movil/features/accounts/infrastructure/repositories/roles_repository_impl.dart';

/// Provider de RolesRemoteDataSource
final rolesRemoteDataSourceProvider = Provider((ref) {
  final dioClient = ref.read(dioClientProvider);
  return RolesRemoteDataSource(dioClient.client);
});

/// Provider de RolesRepository
final rolesRepositoryProvider = Provider<RolesRepository>((ref) {
  final dataSource = ref.read(rolesRemoteDataSourceProvider);
  return RolesRepositoryImpl(remoteDataSource: dataSource);
});

// ============================================================================
// USE CASES PROVIDERS
// ============================================================================

/// Provider del caso de uso ListRoles
final listRolesUseCaseProvider = Provider((ref) {
  final repository = ref.read(rolesRepositoryProvider);
  return ListRoles(repository);
});

/// Provider del caso de uso GetRole
final getRoleUseCaseProvider = Provider((ref) {
  final repository = ref.read(rolesRepositoryProvider);
  return GetRole(repository);
});

/// Provider del caso de uso CreateRole
final createRoleUseCaseProvider = Provider((ref) {
  final repository = ref.read(rolesRepositoryProvider);
  return CreateRole(repository);
});

/// Provider del caso de uso UpdateRole
final updateRoleUseCaseProvider = Provider((ref) {
  final repository = ref.read(rolesRepositoryProvider);
  return UpdateRole(repository);
});

/// Provider del caso de uso DeleteRole
final deleteRoleUseCaseProvider = Provider((ref) {
  final repository = ref.read(rolesRepositoryProvider);
  return DeleteRole(repository);
});

// ============================================================================
// DATA PROVIDERS
// ============================================================================

/// State de búsqueda de roles
final rolesSearchProvider = StateProvider<String>((ref) => '');

/// Provider para obtener lista de roles
final rolesListProvider = FutureProvider.autoDispose<List<Role>>((ref) async {
  final useCase = ref.read(listRolesUseCaseProvider);
  final search = ref.watch(rolesSearchProvider);

  final result = await useCase(search: search.isNotEmpty ? search : null);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (roles) => roles,
  );
});

/// Provider para obtener un rol específico
final roleDetailProvider = FutureProvider.autoDispose.family<Role, String>((
  ref,
  roleId,
) async {
  final useCase = ref.read(getRoleUseCaseProvider);

  final result = await useCase(roleId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (role) => role,
  );
});
