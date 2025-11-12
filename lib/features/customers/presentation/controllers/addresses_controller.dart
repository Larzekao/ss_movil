import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/exceptions/app_exceptions.dart';
import 'package:ss_movil/core/providers/dio_provider.dart';
import 'package:ss_movil/features/customers/application/usecases/create_address_usecase.dart';
import 'package:ss_movil/features/customers/application/usecases/list_addresses_usecase.dart';
import 'package:ss_movil/features/customers/application/usecases/set_principal_address_usecase.dart';
import 'package:ss_movil/features/customers/domain/entities/direccion.dart';
import 'package:ss_movil/features/customers/domain/repositories/customers_repository.dart';
import 'package:ss_movil/features/customers/infrastructure/datasources/customers_remote_datasource.dart';
import 'package:ss_movil/features/customers/infrastructure/repositories/customers_repository_impl.dart';
import 'package:ss_movil/features/customers/presentation/controllers/addresses_state.dart';

class AddressesController extends StateNotifier<AddressesState> {
  final ListAddressesUseCase listAddressesUseCase;
  final CreateAddressUseCase createAddressUseCase;
  final SetPrincipalAddressUseCase setPrincipalAddressUseCase;
  final CustomersRepository repository;

  AddressesController({
    required this.listAddressesUseCase,
    required this.createAddressUseCase,
    required this.setPrincipalAddressUseCase,
    required this.repository,
  }) : super(AddressesState());

  /// Carga la lista de direcciones
  Future<void> load() async {
    try {
      state = state.copyWith(loading: true, error: null);
      final items = await listAddressesUseCase();
      state = state.copyWith(items: items, loading: false);
    } on AppException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Error desconocido: $e');
    }
  }

  /// Crea una nueva dirección
  Future<void> create({
    required String etiqueta,
    required String direccionCompleta,
  }) async {
    try {
      state = state.copyWith(loading: true, error: null);
      final nueva = await createAddressUseCase(
        etiqueta: etiqueta,
        direccionCompleta: direccionCompleta,
      );

      // Si es la primera dirección, es principal automáticamente
      final items = state.items;
      final isDirecciones = items.isEmpty;

      final nuevaDir = Direccion(
        id: nueva.id,
        etiqueta: nueva.etiqueta,
        direccionCompleta: nueva.direccionCompleta,
        esPrincipal: isDirecciones ? true : nueva.esPrincipal,
      );

      state = state.copyWith(items: [...items, nuevaDir], loading: false);
    } on AppException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Error desconocido: $e');
    }
  }

  /// Actualiza una dirección existente
  Future<void> update({
    required int id,
    required String etiqueta,
    required String direccionCompleta,
  }) async {
    try {
      state = state.copyWith(error: null);
      final updated = await repository.updateAddress(
        id: id,
        etiqueta: etiqueta,
        direccionCompleta: direccionCompleta,
      );

      final items = state.items.map((d) => d.id == id ? updated : d).toList();
      state = state.copyWith(items: items);
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (e) {
      state = state.copyWith(error: 'Error desconocido: $e');
    }
  }

  /// Elimina una dirección
  Future<void> delete(int id) async {
    try {
      state = state.copyWith(error: null);
      await repository.deleteAddress(id);

      final items = state.items.where((d) => d.id != id).toList();
      state = state.copyWith(items: items);
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (e) {
      state = state.copyWith(error: 'Error desconocido: $e');
    }
  }

  /// Establece una dirección como principal (optimistic update)
  Future<void> setPrincipal(int id) async {
    try {
      state = state.copyWith(error: null);

      // Optimistic update: actualiza UI inmediatamente
      final items = state.items.map((d) {
        return Direccion(
          id: d.id,
          etiqueta: d.etiqueta,
          direccionCompleta: d.direccionCompleta,
          esPrincipal: d.id == id,
        );
      }).toList();
      state = state.copyWith(items: items);

      // Luego confirma con backend
      final updated = await setPrincipalAddressUseCase(id);

      // Si la respuesta difiere, actualiza con la verdad del servidor
      final finalItems = state.items.map((d) {
        if (d.id == id) return updated;
        return Direccion(
          id: d.id,
          etiqueta: d.etiqueta,
          direccionCompleta: d.direccionCompleta,
          esPrincipal: false,
        );
      }).toList();
      state = state.copyWith(items: finalItems);
    } on AppException catch (e) {
      // Revertir cambios optimistas
      await load();
      state = state.copyWith(error: e.message);
    } catch (e) {
      await load();
      state = state.copyWith(error: 'Error desconocido: $e');
    }
  }

  /// Limpia el estado
  void clear() {
    state = AddressesState();
  }
}

/// Proveedor de Riverpod para ListAddressesUseCase
final listAddressesUseCaseProvider = Provider<ListAddressesUseCase>((ref) {
  final repository = ref.watch(customersRepositoryProvider);
  return ListAddressesUseCase(repository);
});

/// Proveedor de Riverpod para CreateAddressUseCase
final createAddressUseCaseProvider = Provider<CreateAddressUseCase>((ref) {
  final repository = ref.watch(customersRepositoryProvider);
  return CreateAddressUseCase(repository);
});

/// Proveedor de Riverpod para SetPrincipalAddressUseCase
final setPrincipalAddressUseCaseProvider = Provider<SetPrincipalAddressUseCase>(
  (ref) {
    final repository = ref.watch(customersRepositoryProvider);
    return SetPrincipalAddressUseCase(repository);
  },
);

/// Proveedor de Riverpod para CustomersRepository (reutilizable)
final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final remoteDataSource = CustomersRemoteDatasource(dio);
  return CustomersRepositoryImpl(remoteDataSource);
});

/// Proveedor de Riverpod para AddressesController
final addressesControllerProvider =
    StateNotifierProvider<AddressesController, AddressesState>((ref) {
      final listAddresses = ref.watch(listAddressesUseCaseProvider);
      final createAddress = ref.watch(createAddressUseCaseProvider);
      final setPrincipal = ref.watch(setPrincipalAddressUseCaseProvider);
      final repository = ref.watch(customersRepositoryProvider);

      return AddressesController(
        listAddressesUseCase: listAddresses,
        createAddressUseCase: createAddress,
        setPrincipalAddressUseCase: setPrincipal,
        repository: repository,
      );
    });
