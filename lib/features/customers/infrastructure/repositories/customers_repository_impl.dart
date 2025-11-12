import 'package:ss_movil/features/customers/domain/entities/cliente.dart';
import 'package:ss_movil/features/customers/domain/entities/direccion.dart';
import 'package:ss_movil/features/customers/domain/entities/preferencias.dart';
import 'package:ss_movil/features/customers/domain/repositories/customers_repository.dart';
import 'package:ss_movil/features/customers/infrastructure/datasources/customers_remote_datasource.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  final CustomersRemoteDatasource remoteDataSource;

  CustomersRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Direccion>> listAddresses() async {
    final dtos = await remoteDataSource.listAddresses();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<Direccion> createAddress({
    required String etiqueta,
    required String direccionCompleta,
  }) async {
    final dto = await remoteDataSource.createAddress(
      etiqueta: etiqueta,
      direccionCompleta: direccionCompleta,
    );
    return dto.toEntity();
  }

  @override
  Future<Direccion> updateAddress({
    required int id,
    required String etiqueta,
    required String direccionCompleta,
  }) async {
    final dto = await remoteDataSource.updateAddress(
      id: id,
      etiqueta: etiqueta,
      direccionCompleta: direccionCompleta,
    );
    return dto.toEntity();
  }

  @override
  Future<void> deleteAddress(int id) async {
    await remoteDataSource.deleteAddress(id);
  }

  @override
  Future<Direccion> setPrincipal(int id) async {
    final dto = await remoteDataSource.setPrincipal(id);
    return dto.toEntity();
  }

  @override
  Future<Cliente> getMe() async {
    final dto = await remoteDataSource.getMe();
    return dto.toEntity();
  }

  @override
  Future<Cliente> updateProfile({String? nombre, String? telefono}) async {
    final dto = await remoteDataSource.updateProfile(
      nombre: nombre,
      telefono: telefono,
    );
    return dto.toEntity();
  }

  @override
  Future<Preferencias> getPreferences() async {
    final dto = await remoteDataSource.getPreferences();
    return dto.toEntity();
  }

  @override
  Future<Preferencias> updatePreferences({
    bool? notificaciones,
    String? idioma,
    String? tallaFavorita,
  }) async {
    final dto = await remoteDataSource.updatePreferences(
      notificaciones: notificaciones,
      idioma: idioma,
      tallaFavorita: tallaFavorita,
    );
    return dto.toEntity();
  }

  @override
  Future<List<int>> listFavorites() async {
    return await remoteDataSource.listFavorites();
  }

  @override
  Future<void> toggleFavorite(int productId) async {
    await remoteDataSource.toggleFavorite(productId);
  }
}
