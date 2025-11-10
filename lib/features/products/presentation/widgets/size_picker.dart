import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/features/products/domain/entities/size.dart';
import 'package:ss_movil/features/products/application/providers/categories_brands_providers.dart';
import 'package:ss_movil/features/products/application/usecases/sizes/list_sizes.dart';

/// Widget reutilizable para seleccionar tallas (selección múltiple)
///
/// Muestra una lista de tallas con búsqueda integrada.
/// Permite seleccionar múltiples tallas.
class SizePicker extends ConsumerStatefulWidget {
  final List<Size>? initialSizes;
  final Function(List<Size>) onSizesSelected;

  const SizePicker({
    super.key,
    this.initialSizes,
    required this.onSizesSelected,
  });

  @override
  ConsumerState<SizePicker> createState() => _SizePickerState();
}

class _SizePickerState extends ConsumerState<SizePicker> {
  final _searchController = TextEditingController();
  List<Size> _allSizes = [];
  List<Size> _filteredSizes = [];
  List<Size> _selectedSizes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedSizes = widget.initialSizes ?? [];
    _loadSizes();
  }

  Future<void> _loadSizes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final useCase = ref.read(listSizesUseCaseProvider);
    final params = const ListSizesParams(
      page: 1,
      limit: 100, // Cargar todas las tallas activas
      isActive: true,
    );
    final result = await useCase(params);

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar tallas';
          _allSizes = [];
          _filteredSizes = [];
        });
      },
      (pagedSizes) {
        setState(() {
          _isLoading = false;
          _allSizes = pagedSizes.results;
          _filteredSizes = pagedSizes.results;
        });
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSizes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSizes = _allSizes;
      } else {
        _filteredSizes = _allSizes
            .where(
              (size) => size.nombre.toLowerCase().contains(query.toLowerCase()) ||
                  size.codigo.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _toggleSize(Size size) {
    setState(() {
      if (_selectedSizes.any((s) => s.id == size.id)) {
        _selectedSizes.removeWhere((s) => s.id == size.id);
      } else {
        _selectedSizes.add(size);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar talla...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterSizes('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _filterSizes,
            enabled: !_isLoading,
          ),
        ),

        // Contador de seleccionadas
        if (_selectedSizes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedSizes.length} talla(s) seleccionada(s)',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),

        // Lista de tallas
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(_errorMessage!),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadSizes,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  : _filteredSizes.isEmpty
                      ? const Center(
                          child: Text('No se encontraron tallas'),
                        )
                      : ListView.builder(
                          itemCount: _filteredSizes.length,
                          itemBuilder: (context, index) {
                            final size = _filteredSizes[index];
                            final isSelected =
                                _selectedSizes.any((s) => s.id == size.id);

                            return CheckboxListTile(
                              secondary: Icon(
                                Icons.straighten,
                                color: isSelected
                                    ? Colors.deepPurple
                                    : Colors.grey,
                              ),
                              title: Text(
                                size.nombre,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.black,
                                ),
                              ),
                              subtitle: Text('Código: ${size.codigo}'),
                              value: isSelected,
                              activeColor: Colors.deepPurple,
                              onChanged: (bool? value) {
                                _toggleSize(size);
                              },
                            );
                          },
                        ),
        ),

        // Botones de acción
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              Row(
                children: [
                  if (_selectedSizes.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedSizes.clear();
                        });
                      },
                      child: const Text(
                        'Limpiar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSizesSelected(_selectedSizes);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Función helper para mostrar el picker en un bottom sheet
Future<List<Size>?> showSizePicker(
  BuildContext context, {
  List<Size>? initialSizes,
}) async {
  List<Size>? selectedSizes = initialSizes;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          // Handle del bottom sheet
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Seleccionar Tallas',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SizePicker(
              initialSizes: initialSizes,
              onSizesSelected: (sizes) {
                selectedSizes = sizes;
              },
            ),
          ),
        ],
      ),
    ),
  );

  return selectedSizes;
}
