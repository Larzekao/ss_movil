import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/providers/app_providers.dart';
import 'package:ss_movil/features/accounts/application/usecases/users/list_users.dart';
import 'package:ss_movil/features/accounts/application/usecases/users/get_user.dart';
import 'package:ss_movil/features/accounts/application/usecases/users/create_user.dart';
import 'package:ss_movil/features/accounts/application/usecases/users/update_user.dart';
import 'package:ss_movil/features/accounts/application/usecases/users/toggle_active_user.dart';
import 'package:ss_movil/features/accounts/application/usecases/users/delete_user.dart';
import 'package:ss_movil/features/accounts/domain/entities/user.dart';
import 'package:ss_movil/features/accounts/domain/repositories/users_repository.dart';
import 'package:ss_movil/features/accounts/infrastructure/datasources/users_remote_datasource.dart';
import 'package:ss_movil/features/accounts/infrastructure/repositories/users_repository_impl.dart';

/// Provider de UsersRemoteDataSource
final usersRemoteDataSourceProvider = Provider((ref) {
  final dioClient = ref.read(dioClientProvider);
  return UsersRemoteDataSource(dioClient.client);
});

/// Provider de UsersRepository
final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final dataSource = ref.read(usersRemoteDataSourceProvider);
  return UsersRepositoryImpl(remoteDataSource: dataSource);
});

// ============================================================================
// USE CASES PROVIDERS
// ============================================================================

/// Provider del caso de uso ListUsers
final listUsersUseCaseProvider = Provider((ref) {
  final repository = ref.read(usersRepositoryProvider);
  return ListUsers(repository);
});

/// Provider del caso de uso GetUser
final getUserUseCaseProvider = Provider((ref) {
  final repository = ref.read(usersRepositoryProvider);
  return GetUser(repository);
});

/// Provider del caso de uso CreateUser
final createUserUseCaseProvider = Provider((ref) {
  final repository = ref.read(usersRepositoryProvider);
  return CreateUser(repository);
});

/// Provider del caso de uso UpdateUser
final updateUserUseCaseProvider = Provider((ref) {
  final repository = ref.read(usersRepositoryProvider);
  return UpdateUser(repository);
});

/// Provider del caso de uso ToggleActiveUser
final toggleActiveUserUseCaseProvider = Provider((ref) {
  final repository = ref.read(usersRepositoryProvider);
  return ToggleActiveUser(repository);
});

/// Provider del caso de uso DeleteUser
final deleteUserUseCaseProvider = Provider((ref) {
  final repository = ref.read(usersRepositoryProvider);
  return DeleteUser(repository);
});

// ============================================================================
// DATA PROVIDERS
// ============================================================================

/// Parámetros para el provider de lista de usuarios
class UsersListParams {
  final int page;
  final int pageSize;
  final String? search;
  final String? roleId;
  final bool? isActive;

  const UsersListParams({
    this.page = 1,
    this.pageSize = 20,
    this.search,
    this.roleId,
    this.isActive,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsersListParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          pageSize == other.pageSize &&
          search == other.search &&
          roleId == other.roleId &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      page.hashCode ^
      pageSize.hashCode ^
      search.hashCode ^
      roleId.hashCode ^
      isActive.hashCode;
}

/// Provider para obtener lista de usuarios con paginación
final usersListProvider = FutureProvider.autoDispose
    .family<PagedUsers, UsersListParams>((ref, params) async {
      final useCase = ref.read(listUsersUseCaseProvider);

      final result = await useCase(
        page: params.page,
        pageSize: params.pageSize,
        search: params.search,
        roleId: params.roleId,
        isActive: params.isActive,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (pagedUsers) => pagedUsers,
      );
    });

/// Provider para obtener un usuario específico
final userDetailProvider = FutureProvider.autoDispose.family<User, String>((
  ref,
  userId,
) async {
  final useCase = ref.read(getUserUseCaseProvider);

  final result = await useCase(userId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (user) => user,
  );
});
