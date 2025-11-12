import 'package:flutter/material.dart';
import '../../domain/value_objects/order_status.dart';

class OrderFiltersBar extends StatefulWidget {
  final OrderStatusEnum? selectedStatus;
  final String? searchQuery;
  final ValueChanged<OrderStatusEnum?> onStatusChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onApply;
  final VoidCallback onClearFilters;

  const OrderFiltersBar({
    super.key,
    this.selectedStatus,
    this.searchQuery,
    required this.onStatusChanged,
    required this.onSearchChanged,
    required this.onApply,
    required this.onClearFilters,
  });

  @override
  State<OrderFiltersBar> createState() => _OrderFiltersBarState();
}

class _OrderFiltersBarState extends State<OrderFiltersBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery ?? '');
  }

  @override
  void didUpdateWidget(OrderFiltersBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _searchController.text = widget.searchQuery ?? '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Buscar por orden, cliente...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filtro de estado
          const Text(
            'Estado',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusFilterChip(null, 'Todos'),
                ...OrderStatusEnum.values.map((status) {
                  return _buildStatusFilterChip(status, status.label);
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onApply,
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Aplicar Filtros'),
                ),
              ),
              const SizedBox(width: 8),
              if (widget.selectedStatus != null ||
                  _searchController.text.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    widget.onClearFilters();
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Limpiar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(OrderStatusEnum? status, String label) {
    final isSelected =
        status == widget.selectedStatus ||
        (status == null && widget.selectedStatus == null);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          widget.onStatusChanged(selected ? status : null);
        },
        selectedColor: Colors.blue[300],
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey,
          width: isSelected ? 2 : 1,
        ),
      ),
    );
  }
}
