import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/core/errors/failures.dart';

import '../../domain/value_objects/order_status.dart';
import '../../providers.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(orderDetailNotifierProvider.notifier).load(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderDetailNotifierProvider);
    final order = state.order;

    // Mostrar SnackBar cuando hay error
    ref.listen(orderDetailNotifierProvider, (previous, current) {
      if (current.error != null) {
        _showErrorSnackBar(context, current.error!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Orden'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: order == null
          ? const Center(child: CircularProgressIndicator())
          : _buildOrderDetail(order, context),
    );
  }

  void _showErrorSnackBar(BuildContext context, Failure failure) {
    String message = 'Error desconocido';

    failure.when(
      network: (msg, status) => message = 'Error de conexión: $msg',
      auth: (msg, status) =>
          message = 'No autorizado. Por favor, inicia sesión nuevamente.',
      server: (msg, status) => message = 'Error del servidor: $msg',
      validation: (msg, errors) => message = 'Error de validación: $msg',
      notFound: (msg, status) => message = 'Orden no encontrada.',
      unknown: (msg) => message = 'Error: $msg',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Widget _buildOrderDetail(order, BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: información principal
            _buildHeaderCard(order),
            const SizedBox(height: 16),

            // Items
            if (order.itemsCount > 0) ...[
              _buildSectionTitle('Items'),
              _buildItemsCard(order),
              const SizedBox(height: 16),
            ],

            // Dirección de envío
            if (order.shippingAddress != null) ...[
              _buildSectionTitle('Dirección de Envío'),
              _buildShippingAddressCard(order),
              const SizedBox(height: 16),
            ],

            // Notas
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              _buildSectionTitle('Notas'),
              _buildNotesCard(order),
              const SizedBox(height: 16),
            ],

            // Timeline
            if (order.timeline != null && order.timeline!.isNotEmpty) ...[
              _buildSectionTitle('Historial'),
              _buildTimelineCard(order.timeline!),
              const SizedBox(height: 16),
            ],

            // Acciones
            _buildActionsSection(order),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(order) {
    Color statusColor = _getStatusColor(order.status.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orden #${order.code}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.createdAt.toString().split('.')[0],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    order.status.label,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            _buildHeaderRow('Cliente:', order.customerName),
            if (order.customerEmail != null)
              _buildHeaderRow('Email:', order.customerEmail!),
            _buildHeaderRow(
              'Total:',
              '${order.currency} ${order.totalAmount.toStringAsFixed(2)}',
              isAmount: true,
            ),
            if (order.paymentMethod != null)
              _buildHeaderRow('Método:', order.paymentMethod!),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isAmount ? FontWeight.bold : FontWeight.w500,
              fontSize: isAmount ? 14 : 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildItemsCard(order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(child: Text('Descripción')),
                const SizedBox(width: 8),
                const Expanded(flex: 0, child: Text('Cantidad')),
              ],
            ),
            const Divider(),
            Text('${order.itemsCount} artículos'),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingAddressCard(order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(order.shippingAddress ?? 'N/A'),
      ),
    );
  }

  Widget _buildNotesCard(order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(order.notes ?? 'N/A'),
      ),
    );
  }

  Widget _buildTimelineCard(timeline) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: timeline.map<Widget>((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, size: 20, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.action,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          entry.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          entry.timestamp.toString().split('.')[0],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionsSection(order) {
    return Column(
      children: [
        // Cambiar estado - SIEMPRE DISPONIBLE
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showChangeStatusDialog(order),
            child: const Text('Cambiar Estado'),
          ),
        ),
        const SizedBox(height: 8),

        // Reembolsar
        if (order.canBeRefunded)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () => _showRefundDialog(order),
              child: const Text('Reembolsar'),
            ),
          ),
        if (order.canBeRefunded) const SizedBox(height: 8),

        // Cancelar
        if (order.canBeCancelled)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _showCancelDialog(order),
              child: const Text('Cancelar'),
            ),
          ),
      ],
    );
  }

  void _showChangeStatusDialog(order) {
    // Estados disponibles basados en el estado actual
    final availableStatuses = <OrderStatusEnum>[
      // Siempre permitir cambiar a estos estados (excluir el estado actual)
      if (order.status.value != OrderStatusEnum.confirmado)
        OrderStatusEnum.confirmado,
      if (order.status.value != OrderStatusEnum.preparando)
        OrderStatusEnum.preparando,
      if (order.status.value != OrderStatusEnum.pagoRecibido)
        OrderStatusEnum.pagoRecibido,
      if (order.status.value != OrderStatusEnum.enviado)
        OrderStatusEnum.enviado,
      if (order.status.value != OrderStatusEnum.entregado)
        OrderStatusEnum.entregado,
      if (order.status.value != OrderStatusEnum.cancelado)
        OrderStatusEnum.cancelado,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableStatuses.length,
            itemBuilder: (context, index) {
              final status = availableStatuses[index];
              return ListTile(
                title: Text(status.label),
                onTap: () async {
                  Navigator.pop(context); // Cerrar diálogo
                  _showLoadingOverlay(context, 'Actualizando estado...');

                  try {
                    // Ejecutar actualización con timeout
                    await Future.wait([
                      ref
                          .read(orderDetailNotifierProvider.notifier)
                          .updateStatus(OrderStatus(status)),
                      Future.delayed(const Duration(seconds: 1)),
                    ]);
                  } catch (e) {
                    // Log error pero continuar
                    print('Error updating status: $e');
                  }

                  // Siempre cerrar el overlay
                  if (mounted && context.mounted) {
                    Navigator.pop(context); // Cerrar loading overlay
                    // Volver a la lista de órdenes
                    context.pop();
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showRefundDialog(order) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reembolsar Orden'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Desea reembolsar esta orden?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Razón (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingOverlay(context, 'Procesando reembolso...');
              await ref
                  .read(orderDetailNotifierProvider.notifier)
                  .refund(
                    reason: reasonController.text.isEmpty
                        ? null
                        : reasonController.text,
                  );
              reasonController.dispose();
              if (mounted && context.mounted) {
                Navigator.pop(context); // Cerrar loading overlay
              }
            },
            child: const Text('Reembolsar'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(order) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Orden'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Está seguro de que desea cancelar esta orden?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Razón (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingOverlay(context, 'Cancelando orden...');
              await ref
                  .read(orderDetailNotifierProvider.notifier)
                  .cancel(
                    reason: reasonController.text.isEmpty
                        ? null
                        : reasonController.text,
                  );
              reasonController.dispose();
              if (mounted && context.mounted) {
                Navigator.pop(context); // Cerrar loading overlay
              }
            },
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showLoadingOverlay(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.pendiente:
        return Colors.orange;
      case OrderStatusEnum.pagoRecibido:
        return Colors.blue;
      case OrderStatusEnum.preparando:
        return Colors.amber;
      case OrderStatusEnum.confirmado:
        return Colors.purple;
      case OrderStatusEnum.enviado:
        return Colors.cyan;
      case OrderStatusEnum.entregado:
        return Colors.green;
      case OrderStatusEnum.cancelado:
        return Colors.red;
      case OrderStatusEnum.reembolsado:
        return Colors.indigo;
    }
  }
}
