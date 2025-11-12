import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/features/customers/presentation/controllers/preferences_controller.dart';

class PreferencesPage extends ConsumerStatefulWidget {
  const PreferencesPage({super.key});

  @override
  ConsumerState<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends ConsumerState<PreferencesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(preferencesControllerProvider.notifier).load(),
    );
  }

  @override
  void dispose() {
    ref.read(preferencesControllerProvider.notifier).clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefsState = ref.watch(preferencesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: prefsState.loading && prefsState.data == null
          ? const Center(child: CircularProgressIndicator())
          : prefsState.error != null && prefsState.data == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar preferencias',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    prefsState.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(preferencesControllerProvider.notifier).load();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : prefsState.data == null
          ? const Center(child: Text('No hay datos'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mensaje de éxito
                  if (prefsState.successMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              prefsState.successMessage!,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (prefsState.successMessage != null)
                    const SizedBox(height: 16),

                  // Mensaje de error
                  if (prefsState.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              prefsState.error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (prefsState.error != null) const SizedBox(height: 16),

                  // Sección: Notificaciones
                  Text(
                    'Notificaciones',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recibir notificaciones',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Notificaciones push sobre pedidos',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                        Switch(
                          value: prefsState.data!.notificaciones,
                          onChanged: (value) {
                            ref
                                .read(preferencesControllerProvider.notifier)
                                .updateWithDebounce(notificaciones: value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sección: Idioma
                  Text(
                    'Idioma',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: prefsState.data!.idioma,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'es', child: Text('Español')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'pt', child: Text('Português')),
                      ],
                      onChanged: (value) {
                        if (value != null && value != prefsState.data!.idioma) {
                          ref
                              .read(preferencesControllerProvider.notifier)
                              .updateWithDebounce(idioma: value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sección: Talla Favorita
                  Text(
                    'Talla Favorita',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButton<String?>(
                      isExpanded: true,
                      value: prefsState.data!.tallaFavorita,
                      underline: const SizedBox(),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Seleccionar talla'),
                        ),
                        const DropdownMenuItem(
                          value: 'XS',
                          child: Text('Extra Pequeño (XS)'),
                        ),
                        const DropdownMenuItem(
                          value: 'S',
                          child: Text('Pequeño (S)'),
                        ),
                        const DropdownMenuItem(
                          value: 'M',
                          child: Text('Mediano (M)'),
                        ),
                        const DropdownMenuItem(
                          value: 'L',
                          child: Text('Grande (L)'),
                        ),
                        const DropdownMenuItem(
                          value: 'XL',
                          child: Text('Extra Grande (XL)'),
                        ),
                        const DropdownMenuItem(
                          value: 'XXL',
                          child: Text('Extra Extra Grande (XXL)'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != prefsState.data!.tallaFavorita) {
                          ref
                              .read(preferencesControllerProvider.notifier)
                              .updateWithDebounce(tallaFavorita: value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Información de sincronización
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Los cambios se guardan automáticamente después de 400ms',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
