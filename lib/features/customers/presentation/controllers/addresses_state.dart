import 'package:ss_movil/features/customers/domain/entities/direccion.dart';

class AddressesState {
  final List<Direccion> items;
  final bool loading;
  final String? error;

  AddressesState({this.items = const [], this.loading = false, this.error});

  AddressesState copyWith({
    List<Direccion>? items,
    bool? loading,
    String? error,
  }) {
    return AddressesState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }

  Direccion? get principal {
    try {
      return items.firstWhere((d) => d.esPrincipal);
    } catch (e) {
      return items.isNotEmpty ? items.first : null;
    }
  }

  @override
  String toString() =>
      'AddressesState(items: ${items.length}, loading: $loading, error: $error)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressesState &&
          runtimeType == other.runtimeType &&
          items == other.items &&
          loading == other.loading &&
          error == other.error;

  @override
  int get hashCode => items.hashCode ^ loading.hashCode ^ error.hashCode;
}
