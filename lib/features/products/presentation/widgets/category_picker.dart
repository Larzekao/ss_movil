import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/features/products/domain/entities/category.dart';
import 'package:ss_movil/features/products/application/providers/categories_brands_providers.dart';
import 'package:ss_movil/features/products/application/usecases/categories/list_categories.dart';

/// Widget reutilizable para seleccionar una categoría
///
/// Muestra una lista de categorías con búsqueda integrada.
/// Retorna la categoría seleccionada al hacer tap.
class CategoryPicker extends ConsumerStatefulWidget {
  final Category? initialCategory;
  final Function(Category?) onCategorySelected;

  const CategoryPicker({
    super.key,
    this.initialCategory,
    required this.onCategorySelected,
  });

  @override
  ConsumerState<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends ConsumerState<CategoryPicker> {
  final _searchController = TextEditingController();
  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  Category? _selectedCategory;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final useCase = ref.read(listCategoriesUseCaseProvider);
    final params = const ListCategoriesParams(
      page: 1,
      limit: 100, // Cargar todas las categorías activas
      isActive: true,
    );
    final result = await useCase(params);

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar categorías';
          _allCategories = [];
          _filteredCategories = [];
        });
      },
      (pagedCategories) {
        setState(() {
          _isLoading = false;
          _allCategories = pagedCategories.results;
          _filteredCategories = pagedCategories.results;
        });
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _allCategories;
      } else {
        _filteredCategories = _allCategories
            .where(
              (cat) => cat.nombre.toLowerCase().contains(query.toLowerCase()),
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
              hintText: 'Buscar categoría...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterCategories('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _filterCategories,
            enabled: !_isLoading,
          ),
        ),

        // Lista de categorías
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
                            onPressed: _loadCategories,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  : _filteredCategories.isEmpty
                      ? const Center(
                          child: Text('No se encontraron categorías'),
                        )
                      : ListView.builder(
                          itemCount: _filteredCategories.length,
                          itemBuilder: (context, index) {
                            final category = _filteredCategories[index];
                            final isSelected =
                                _selectedCategory?.id == category.id;

                            return ListTile(
                              leading: Icon(
                                Icons.category,
                                color: isSelected
                                    ? Colors.deepPurple
                                    : Colors.grey,
                              ),
                              title: Text(
                                category.nombre,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.black,
                                ),
                              ),
                              subtitle: category.descripcion != null
                                  ? Text(category.descripcion!)
                                  : null,
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.deepPurple,
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                                widget.onCategorySelected(category);
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
                  widget.onCategorySelected(null);
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              if (_selectedCategory != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                    widget.onCategorySelected(null);
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
Future<Category?> showCategoryPicker(
  BuildContext context, {
  Category? initialCategory,
}) async {
  Category? selectedCategory = initialCategory;

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
              'Seleccionar Categoría',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: CategoryPicker(
              initialCategory: initialCategory,
              onCategorySelected: (category) {
                selectedCategory = category;
              },
            ),
          ),
        ],
      ),
    ),
  );

  return selectedCategory;
}
