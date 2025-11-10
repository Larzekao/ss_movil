import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/features/products/domain/entities/brand.dart';
import 'package:ss_movil/features/products/application/providers/categories_brands_providers.dart';
import 'package:ss_movil/features/products/application/usecases/brands/list_brands.dart';

/// Widget reutilizable para seleccionar una marca
///
/// Muestra una lista de marcas con búsqueda integrada.
/// Retorna la marca seleccionada al hacer tap.
class BrandPicker extends ConsumerStatefulWidget {
  final Brand? initialBrand;
  final Function(Brand?) onBrandSelected;

  const BrandPicker({
    super.key,
    this.initialBrand,
    required this.onBrandSelected,
  });

  @override
  ConsumerState<BrandPicker> createState() => _BrandPickerState();
}

class _BrandPickerState extends ConsumerState<BrandPicker> {
  final _searchController = TextEditingController();
  List<Brand> _allBrands = [];
  List<Brand> _filteredBrands = [];
  Brand? _selectedBrand;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedBrand = widget.initialBrand;
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final useCase = ref.read(listBrandsUseCaseProvider);
    final params = const ListBrandsParams(
      page: 1,
      limit: 100, // Cargar todas las marcas activas
      isActive: true,
    );
    final result = await useCase(params);

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar marcas';
          _allBrands = [];
          _filteredBrands = [];
        });
      },
      (pagedBrands) {
        setState(() {
          _isLoading = false;
          _allBrands = pagedBrands.results;
          _filteredBrands = pagedBrands.results;
        });
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBrands(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBrands = _allBrands;
      } else {
        _filteredBrands = _allBrands
            .where(
              (brand) =>
                  brand.nombre.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
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
              hintText: 'Buscar marca...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterBrands('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _filterBrands,
            enabled: !_isLoading,
          ),
        ),

        // Lista de marcas
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
                            onPressed: _loadBrands,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  : _filteredBrands.isEmpty
                      ? const Center(
                          child: Text('No se encontraron marcas'),
                        )
                      : ListView.builder(
                          itemCount: _filteredBrands.length,
                          itemBuilder: (context, index) {
                            final brand = _filteredBrands[index];
                            final isSelected =
                                _selectedBrand?.id == brand.id;

                            return ListTile(
                              leading: Icon(
                                Icons.business,
                                color: isSelected
                                    ? Colors.deepPurple
                                    : Colors.grey,
                              ),
                              title: Text(
                                brand.nombre,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.black,
                                ),
                              ),
                              subtitle: brand.descripcion != null
                                  ? Text(brand.descripcion!)
                                  : null,
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.deepPurple,
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedBrand = brand;
                                });
                                widget.onBrandSelected(brand);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
        ),

        // Botón para cancelar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  widget.onBrandSelected(null);
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              if (_selectedBrand != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedBrand = null;
                    });
                    widget.onBrandSelected(null);
                  },
                  child: const Text(
                    'Limpiar selección',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Función helper para mostrar el picker en un bottom sheet
Future<Brand?> showBrandPicker(
  BuildContext context, {
  Brand? initialBrand,
}) async {
  Brand? selectedBrand = initialBrand;

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
              'Seleccionar Marca',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: BrandPicker(
              initialBrand: initialBrand,
              onBrandSelected: (brand) {
                selectedBrand = brand;
              },
            ),
          ),
        ],
      ),
    ),
  );

  return selectedBrand;
}
