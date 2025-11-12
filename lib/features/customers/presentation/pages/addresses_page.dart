import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/features/customers/domain/entities/direccion.dart';
import 'package:ss_movil/features/customers/presentation/controllers/addresses_controller.dart';

class AddressesPage extends ConsumerStatefulWidget {
  const AddressesPage({super.key});

  @override
  ConsumerState<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends ConsumerState<AddressesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(addressesControllerProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressesState = ref.watch(addressesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Direcciones'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: addressesState.loading && addressesState.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : addressesState.error != null && addressesState.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar direcciones',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    addressesState.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(addressesControllerProvider.notifier).load();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : addressesState.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes direcciones registradas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Primera Dirección'),
                    onPressed: () =>
                        _showAddressForm(context, addressController: null),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addressesState.items.length,
              itemBuilder: (context, index) {
                final address = addressesState.items[index];
                return _buildAddressCard(context, address);
              },
            ),
      floatingActionButton: addressesState.items.isNotEmpty
          ? FloatingActionButton(
              onPressed: () =>
                  _showAddressForm(context, addressController: null),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildAddressCard(BuildContext context, Direccion address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: Radio<int>(
              value: address.id,
              groupValue:
                  ref.read(addressesControllerProvider).principal?.id ?? -1,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(addressesControllerProvider.notifier)
                      .setPrincipal(value);
                }
              },
            ),
            title: Text(
              address.etiqueta,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(address.direccionCompleta),
                const SizedBox(height: 4),
                if (address.esPrincipal)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Principal',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            isThreeLine: true,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                  onPressed: () =>
                      _showAddressForm(context, addressController: address),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Eliminar'),
                  onPressed: () => _showDeleteConfirmation(context, address),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressForm(
    BuildContext context, {
    required Direccion? addressController,
  }) {
    final etiquetaController = TextEditingController(
      text: addressController?.etiqueta ?? '',
    );
    final direccionController = TextEditingController(
      text: addressController?.direccionCompleta ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addressController == null
                      ? 'Agregar Dirección'
                      : 'Editar Dirección',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: etiquetaController,
                  decoration: InputDecoration(
                    labelText: 'Etiqueta (Casa, Oficina, etc.)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: direccionController,
                  decoration: InputDecoration(
                    labelText: 'Dirección Completa',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Calle, número, ciudad, país',
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (etiquetaController.text.isEmpty ||
                          direccionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Por favor completa todos los campos',
                            ),
                          ),
                        );
                        return;
                      }

                      if (addressController == null) {
                        await ref
                            .read(addressesControllerProvider.notifier)
                            .create(
                              etiqueta: etiquetaController.text,
                              direccionCompleta: direccionController.text,
                            );
                      } else {
                        await ref
                            .read(addressesControllerProvider.notifier)
                            .update(
                              id: addressController.id,
                              etiqueta: etiquetaController.text,
                              direccionCompleta: direccionController.text,
                            );
                      }

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      addressController == null ? 'Agregar' : 'Guardar Cambios',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Direccion address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Dirección'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la dirección "${address.etiqueta}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(addressesControllerProvider.notifier)
                  .delete(address.id);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
