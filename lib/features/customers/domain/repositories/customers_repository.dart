import 'package:ss_movil/features/customers/domain/entities/cliente.dart';
import 'package:ss_movil/features/customers/domain/entities/direccion.dart';
import 'package:ss_movil/features/customers/domain/entities/preferencias.dart';

abstract class CustomersRepository {
  // Direcciones
  Future<List<Direccion>> listAddresses();
  Future<Direccion> createAddress({
    required String etiqueta,
    required String direccionCompleta,
  });
  Future<Direccion> updateAddress({
    required int id,
    required String etiqueta,
    required String direccionCompleta,
  });
  Future<void> deleteAddress(int id);
  Future<Direccion> setPrincipal(int id);

  // Perfil
  Future<Cliente> getMe();
  Future<Cliente> updateProfile({String? nombre, String? telefono});

  // Preferencias
  Future<Preferencias> getPreferences();
  Future<Preferencias> updatePreferences({
    bool? notificaciones,
    String? idioma,
    String? tallaFavorita,
  });

  // Favoritos
  Future<List<int>> listFavorites();
  Future<void> toggleFavorite(int productId);
}
