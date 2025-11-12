import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';
import '../../domain/value_objects/order_status.dart';

class OrderListItem extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderListItem({super.key, required this.order, required this.onTap});

  Color _getStatusColor() {
    switch (order.status.value) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(
          'Orden #${order.code}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(order.customerName, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.currency} ${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(), width: 1),
                  ),
                  child: Text(
                    order.status.label,
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
