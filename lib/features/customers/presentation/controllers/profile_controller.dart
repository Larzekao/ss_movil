import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/exceptions/app_exceptions.dart';
import 'package:ss_movil/core/providers/dio_provider.dart';
import 'package:ss_movil/features/customers/application/usecases/get_me_usecase.dart';
import 'package:ss_movil/features/customers/application/usecases/update_profile_usecase.dart';
import 'package:ss_movil/features/customers/domain/repositories/customers_repository.dart';
import 'package:ss_movil/features/customers/infrastructure/datasources/customers_remote_datasource.dart';
import 'package:ss_movil/features/customers/infrastructure/repositories/customers_repository_impl.dart';
import 'package:ss_movil/features/customers/presentation/controllers/profile_state.dart';

class ProfileController extends StateNotifier<ProfileState> {
  final GetMeUseCase getMeUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileController({
    required this.getMeUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileState());

  /// Carga el perfil del usuario actual
  Future<void> loadMe() async {
    try {
      state = state.copyWith(loading: true, error: null);
      final me = await getMeUseCase();
      state = state.copyWith(me: me, loading: false);
    } on AppException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Error desconocido: $e');
    }
  }

  /// Actualiza el perfil del usuario
  Future<void> updateProfile({String? nombre, String? telefono}) async {
    try {
      state = state.copyWith(loading: true, error: null);
      final updated = await updateProfileUseCase(
        nombre: nombre,
        telefono: telefono,
      );
      state = state.copyWith(me: updated, loading: false);
    } on AppException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Error desconocido: $e');
    }
  }

  /// Limpia el estado del perfil
  void clear() {
    state = ProfileState();
  }
}

/// Proveedor de Riverpod para CustomersRepository
final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final remoteDataSource = CustomersRemoteDatasource(dio);
  return CustomersRepositoryImpl(remoteDataSource);
});

/// Proveedor de Riverpod para GetMeUseCase
final getMeUseCaseProvider = Provider<GetMeUseCase>((ref) {
  final repository = ref.watch(customersRepositoryProvider);
  return GetMeUseCase(repository);
});

/// Proveedor de Riverpod para UpdateProfileUseCase
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(customersRepositoryProvider);
  return UpdateProfileUseCase(repository);
});

/// Proveedor de Riverpod para ProfileController
final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
      final getMe = ref.watch(getMeUseCaseProvider);
      final updateProfile = ref.watch(updateProfileUseCaseProvider);
      return ProfileController(
        getMeUseCase: getMe,
        updateProfileUseCase: updateProfile,
      );
    });
