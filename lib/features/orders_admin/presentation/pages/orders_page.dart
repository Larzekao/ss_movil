import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/core/errors/failures.dart';
import '../../domain/value_objects/order_status.dart';
import '../../providers.dart';
import '../controllers/orders_controller.dart';
import '../widgets/order_list_item.dart';
import '../widgets/order_filters_bar.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Cargar primera página
    Future.microtask(() {
      final filter = ref.read(ordersFilterProvider);
      ref.read(ordersNotifierProvider.notifier).fetchFirstPage(filter);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      final state = ref.read(ordersNotifierProvider);
      if (state.hasMore && state.error == null) {
        final filter = ref.read(ordersFilterProvider);
        ref.read(ordersNotifierProvider.notifier).fetchNextPage(filter);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersNotifierProvider);
    final filter = ref.watch(ordersFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Órdenes'), elevation: 0),
      body: Column(
        children: [
          // Filtros
          OrderFiltersBar(
            selectedStatus: filter.status != null
                ? OrderStatusEnum.values.firstWhere(
                    (e) => e.code == filter.status,
                    orElse: () => OrderStatusEnum.pendiente,
                  )
                : null,
            searchQuery: filter.searchQuery,
            onStatusChanged: (status) {
              ref.read(ordersFilterProvider.notifier).setStatus(status?.code);
              ref
                  .read(ordersNotifierProvider.notifier)
                  .applyFilters(ref.read(ordersFilterProvider));
            },
            onSearchChanged: (query) {
              ref.read(ordersFilterProvider.notifier).setSearch(query);
            },
            onApply: () {
              ref
                  .read(ordersNotifierProvider.notifier)
                  .applyFilters(ref.read(ordersFilterProvider));
            },
            onClearFilters: () {
              ref.read(ordersFilterProvider.notifier).reset();
              ref
                  .read(ordersNotifierProvider.notifier)
                  .refresh(const OrdersFilter());
            },
          ),
          // Listado de órdenes
          Expanded(child: _buildOrdersList(state, context)),
        ],
      ),
    );
  }

  Widget _buildOrdersList(OrdersState state, BuildContext context) {
    if (state.allOrders.isEmpty && state.error == null) {
      return const Center(child: Text('No hay órdenes para mostrar'));
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _formatError(state.error),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final filter = ref.read(ordersFilterProvider);
                ref.read(ordersNotifierProvider.notifier).refresh(filter);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.allOrders.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Mostrar spinner de carga al final
        if (index == state.allOrders.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final order = state.allOrders[index];
        return OrderListItem(
          order: order,
          onTap: () {
            context.push('/admin/orders/${order.id}');
          },
        );
      },
    );
  }

  String _formatError(dynamic error) {
    if (error == null) return 'Error desconocido';

    if (error is! Failure) {
      return error.toString();
    }

    return error.maybeWhen(
      network: (msg, status) => 'Error de conexión: $msg',
      auth: (msg, status) =>
          'No autorizado. Por favor, inicia sesión nuevamente.',
      server: (msg, status) => 'Error del servidor: $msg',
      validation: (msg, errors) => 'Error de validación: $msg',
      notFound: (msg, status) => 'Órdenes no encontradas',
      unknown: (msg) => msg,
      orElse: () => 'Error desconocido',
    );
  }
}
