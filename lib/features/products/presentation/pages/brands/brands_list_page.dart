import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/core/providers/app_providers.dart';
import 'package:ss_movil/features/products/domain/entities/brand.dart';
import 'package:ss_movil/features/products/presentation/providers/brands_ui_provider.dart';
import 'package:ss_movil/shared/widgets/can.dart';
import 'package:ss_movil/shared/widgets/accounts_drawer.dart';

/// Página de lista de marcas - Versión simplificada (lista simple)
class BrandsListPage extends ConsumerStatefulWidget {
  const BrandsListPage({super.key});

  @override
  ConsumerState<BrandsListPage> createState() => _BrandsListPageState();
}

class _BrandsListPageState extends ConsumerState<BrandsListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(brandsProvider.notifier).loadBrands(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = ref.read(brandsProvider);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !state.isLoading &&
        state.hasMore) {
      ref.read(brandsProvider.notifier).loadBrands(page: state.currentPage + 1);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref
        .read(brandsProvider.notifier)
        .loadBrands(search: query.isEmpty ? null : query, refresh: true);
  }

  Future<void> _onRefresh() async {
    await ref.read(brandsProvider.notifier).loadBrands(refresh: true);
  }

  void _showDeleteDialog(Brand brand) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Marca'),
        content: Text('¿Estás seguro de eliminar "${brand.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(brandsProvider.notifier).deleteBrand(brand.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Marca eliminada'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final state = ref.watch(brandsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marcas'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          Can(
            permissionCode: 'marcas.crear',
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.go('/brands/new'),
            ),
          ),
        ],
      ),
      drawer: authState.maybeWhen(
        authenticated: (user) =>
            AccountsDrawer(user: user, currentRoute: '/brands'),
        orElse: () => null,
      ),
      body: Column(
        children: [
          // Búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Buscar marcas...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          // Contador
          if (state.totalItems > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${state.totalItems} marcas',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          const SizedBox(height: 8),
          // Lista
          Expanded(
            child: state.isLoading && state.brands.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.brands.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.branding_watermark,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text('No hay marcas'),
                        const SizedBox(height: 24),
                        Can(
                          permissionCode: 'marcas.crear',
                          child: ElevatedButton.icon(
                            onPressed: () => context.go('/brands/new'),
                            icon: const Icon(Icons.add),
                            label: const Text('Nueva Marca'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount:
                          state.brands.length + (state.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.brands.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final brand = state.brands[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: brand.logo != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        brand.logo!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.branding_watermark,
                                              color: Colors.grey,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.branding_watermark,
                                      color: Colors.grey,
                                    ),
                            ),
                            title: Text(brand.nombre),
                            subtitle: Text(
                              brand.descripcion ?? 'Sin descripción',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: brand.activo
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    brand.activo ? 'Activa' : 'Inactiva',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      onTap: () => Future.delayed(
                                        const Duration(milliseconds: 100),
                                        () => context.go(
                                          '/brands/${brand.id}/edit',
                                        ),
                                      ),
                                      child: const Text('Editar'),
                                    ),
                                    PopupMenuItem(
                                      onTap: () => Future.delayed(
                                        const Duration(milliseconds: 100),
                                        () => _showDeleteDialog(brand),
                                      ),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Can(
        permissionCode: 'marcas.crear',
        child: FloatingActionButton(
          backgroundColor: Colors.purple,
          onPressed: () => context.go('/brands/new'),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
