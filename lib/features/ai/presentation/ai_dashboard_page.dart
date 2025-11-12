import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'ai_controller.dart';
import '../domain/ai_models.dart';
import '../utils/ai_export.dart';
import '../data/ai_fallback_data.dart';

class AiDashboardPage extends ConsumerStatefulWidget {
  const AiDashboardPage({super.key});

  @override
  ConsumerState<AiDashboardPage> createState() => _AiDashboardPageState();
}

class _AiDashboardPageState extends ConsumerState<AiDashboardPage> {
  String? _selectedCategoria;
  final List<String> _categorias = [
    'Todas',
    'Electrónica',
    'Ropa',
    'Alimentos',
    'Hogar',
  ];

  // GlobalKey para capturar el gráfico
  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Cargar dashboard al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiControllerProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        title: const Text('IA — Predicciones'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(aiControllerProvider.notifier).loadDashboard();
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(AiState state) {
    return switch (state) {
      AiIdle() => _buildInitialState(),
      AiLoading() => _buildLoadingState(),
      AiDashboardOk() => _buildDashboardContent(state.dashboard),
      AiForecastOk() => _buildForecastContent(state.forecast),
      AiModelOk() => _buildModelInfo(state.model),
      AiError() => _buildErrorState(state.message),
    };
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Cargando predicciones de IA...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue[700]),
          const SizedBox(height: 16),
          const Text('Procesando datos...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(aiControllerProvider.notifier).loadDashboard();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[300]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber[800], size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo Sin Modelo de IA',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No hay un modelo de IA entrenado. Entrena uno para obtener predicciones reales.',
                  style: TextStyle(fontSize: 13, color: Colors.amber[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastFallbackBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[300]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange[800],
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Predicción No Disponible',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'El modelo de IA aún no está entrenado. Entrena el modelo desde el dashboard para generar predicciones.',
                  style: TextStyle(fontSize: 13, color: Colors.orange[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(AiDashboardResponse dashboard) {
    // Detectar si es fallback
    final isFallback = AiFallbackData.isFallbackDashboard(dashboard);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner informativo si es fallback
          if (isFallback) _buildFallbackBanner(),
          if (isFallback) const SizedBox(height: 20),

          // KPIs Cards
          _buildKpiCards(dashboard.metrics),
          const SizedBox(height: 20),

          // Chips de Pronóstico Rápido
          _buildQuickForecastChips(),
          const SizedBox(height: 20),

          // Selector de Categoría
          _buildCategorySelector(),
          const SizedBox(height: 20),

          // Botones de Acción
          _buildActionButtons(),
          const SizedBox(height: 20),

          // Modelo Activo Info
          if (dashboard.activeModel != null)
            _buildActiveModelCard(dashboard.activeModel!),
          const SizedBox(height: 20),

          // Predicciones Recientes
          if (dashboard.recentPredictions.isNotEmpty)
            _buildRecentPredictionsCard(dashboard.recentPredictions),
        ],
      ),
    );
  }

  Widget _buildKpiCards(List<MetricItem> metrics) {
    // Si hay menos de 4 métricas, agregar placeholders
    final displayMetrics = List<MetricItem>.from(metrics);
    while (displayMetrics.length < 4) {
      displayMetrics.add(const MetricItem(label: 'N/A', value: '--'));
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: displayMetrics.take(4).map((metric) {
        return _buildKpiCard(
          label: metric.label,
          value: metric.value.toString(),
          unit: metric.unit,
          trend: metric.trend,
        );
      }).toList(),
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    String? unit,
    String? trend,
  }) {
    IconData? trendIcon;
    Color? trendColor;

    if (trend != null) {
      switch (trend.toLowerCase()) {
        case 'up':
          trendIcon = Icons.trending_up;
          trendColor = Colors.green;
          break;
        case 'down':
          trendIcon = Icons.trending_down;
          trendColor = Colors.red;
          break;
        case 'stable':
          trendIcon = Icons.trending_flat;
          trendColor = Colors.orange;
          break;
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (unit != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      unit,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                if (trendIcon != null)
                  Icon(trendIcon, color: trendColor, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickForecastChips() {
    final state = ref.watch(aiControllerProvider);
    final isLoading = state is AiLoading;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Pronósticos Rápidos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Generando pronóstico...'),
                    ],
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildForecastChip(
                    label: 'Pronóstico total 3m',
                    icon: Icons.show_chart,
                    color: Colors.green,
                    onTap: () {
                      ref
                          .read(aiControllerProvider.notifier)
                          .getForecast(nMonths: 3, categoria: null);
                    },
                  ),
                  _buildForecastChip(
                    label: 'Pronóstico total 6m',
                    icon: Icons.timeline,
                    color: Colors.blue,
                    onTap: () {
                      ref
                          .read(aiControllerProvider.notifier)
                          .getForecast(nMonths: 6, categoria: null);
                    },
                  ),
                  if (_selectedCategoria != null &&
                      _selectedCategoria != 'Todas')
                    _buildForecastChip(
                      label: 'Pronóstico $_selectedCategoria 3m',
                      icon: Icons.category,
                      color: Colors.purple,
                      onTap: () {
                        ref
                            .read(aiControllerProvider.notifier)
                            .getForecast(
                              nMonths: 3,
                              categoria: _selectedCategoria,
                            );
                      },
                    ),
                  if (_selectedCategoria != null &&
                      _selectedCategoria != 'Todas')
                    _buildForecastChip(
                      label: 'Pronóstico $_selectedCategoria 6m',
                      icon: Icons.category,
                      color: Colors.deepPurple,
                      onTap: () {
                        ref
                            .read(aiControllerProvider.notifier)
                            .getForecast(
                              nMonths: 6,
                              categoria: _selectedCategoria,
                            );
                      },
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.category, color: Colors.blue),
            const SizedBox(width: 12),
            const Text(
              'Categoría:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String>(
                value: _selectedCategoria,
                hint: const Text('Todas'),
                isExpanded: true,
                underline: const SizedBox(),
                items: _categorias.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategoria = value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final categoria = _selectedCategoria == 'Todas'
                  ? null
                  : _selectedCategoria;
              ref
                  .read(aiControllerProvider.notifier)
                  .getForecast(nMonths: 3, categoria: categoria);
            },
            icon: const Icon(Icons.auto_graph),
            label: const Text('Pronosticar 3 meses'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final categoria = _selectedCategoria == 'Todas'
                  ? null
                  : _selectedCategoria;
              ref
                  .read(aiControllerProvider.notifier)
                  .getForecast(nMonths: 6, categoria: categoria);
            },
            icon: const Icon(Icons.timeline),
            label: const Text('Pronosticar 6 meses'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveModelCard(AiModelInfo model) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.model_training, color: Colors.blue[700]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Modelo Activo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        model.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(model.status),
              ],
            ),
            const SizedBox(height: 12),
            if (model.accuracy != null)
              Row(
                children: [
                  const Text(
                    'Precisión: ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('${(model.accuracy! * 100).toStringAsFixed(1)}%'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: model.accuracy,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(Colors.green[600]),
                    ),
                  ),
                ],
              ),
            if (model.trainedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Entrenado: ${_formatDate(model.trainedAt!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'training':
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case 'ready':
        color = Colors.blue;
        icon = Icons.done;
        break;
      case 'failed':
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPredictionsCard(List<PredictionHistoryItem> predictions) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Predicciones Recientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...predictions.take(5).map((pred) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.analytics, color: Colors.blue[700]),
                title: Text(pred.type),
                subtitle: Text(_formatDate(pred.createdAt)),
                trailing: const Icon(Icons.chevron_right),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastContent(AiForecastResponse forecast) {
    // Detectar si es fallback
    final isFallback = AiFallbackData.isFallbackForecast(forecast);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner informativo si es fallback
          if (isFallback) _buildForecastFallbackBanner(),
          if (isFallback) const SizedBox(height: 16),

          // Header Card con gradiente
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[700]!, Colors.purple[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_graph,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Predicción de Ventas',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Generado: ${_formatDate(forecast.generatedAt)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  if (forecast.modelUsed != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.model_training,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Modelo: ${forecast.modelUsed}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // KPIs del Forecast
          if (forecast.kpis.isNotEmpty) _buildForecastKpis(forecast.kpis),
          const SizedBox(height: 20),

          // Gráfico de línea (simple)
          RepaintBoundary(
            key: _chartKey,
            child: _buildSimpleLineChart(forecast.forecast),
          ),
          const SizedBox(height: 20),

          // Botones de exportar/compartir
          _buildExportButtons(forecast),
          const SizedBox(height: 20),

          // Botón para volver
          ElevatedButton.icon(
            onPressed: () {
              ref.read(aiControllerProvider.notifier).loadDashboard();
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver al Dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButtons(AiForecastResponse forecast) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.download, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Exportar Datos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleExportCsv(forecast),
                    icon: const Icon(Icons.table_chart, size: 20),
                    label: const Text('Exportar CSV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleShareChart,
                    icon: const Icon(Icons.share, size: 20),
                    label: const Text('Compartir Gráfico'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExportCsv(AiForecastResponse forecast) async {
    try {
      // Mostrar loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Exportando CSV...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Exportar y compartir
      await AiExport.exportAndShareCsv(forecast);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('CSV exportado exitosamente'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _handleShareChart() async {
    try {
      // Mostrar loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Capturando gráfico...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Capturar y compartir
      await AiExport.captureChartAndShare(_chartKey);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Gráfico compartido exitosamente'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildForecastKpis(Map<String, dynamic> kpis) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Indicadores Clave',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...kpis.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text(
                      entry.value.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleLineChart(List<ForecastPoint> points) {
    if (points.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text('No hay datos para mostrar')),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Serie Temporal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: CustomPaint(
                painter: SimpleLineChartPainter(points),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Histórico', Colors.blue),
                const SizedBox(width: 20),
                _buildLegendItem('Predicción', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 3, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildModelInfo(AiModelInfo model) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.model_training, size: 80, color: Colors.blue[700]),
            const SizedBox(height: 16),
            Text(
              model.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStatusChip(model.status),
            if (model.accuracy != null) ...[
              const SizedBox(height: 16),
              Text(
                'Precisión: ${(model.accuracy! * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 16),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(aiControllerProvider.notifier).loadDashboard();
              },
              child: const Text('Ver Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// CustomPainter para gráfico de línea simple
class SimpleLineChartPainter extends CustomPainter {
  final List<ForecastPoint> points;

  SimpleLineChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // Calcular escalas
    final maxValue = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final minValue = points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
    if (range == 0) return;

    final xStep = size.width / (points.length - 1);
    final yScale = size.height / range;

    // Separar histórico y predicción
    final historicos = points.where((p) => p.isHistorical).toList();
    final predicciones = points.where((p) => !p.isHistorical).toList();

    // Dibujar línea histórica (azul sólido)
    if (historicos.isNotEmpty) {
      final paintHistorico = Paint()
        ..color = Colors.blue
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final pathHistorico = Path();
      for (var i = 0; i < historicos.length; i++) {
        final x = i * xStep;
        final y = size.height - (historicos[i].value - minValue) * yScale;
        if (i == 0) {
          pathHistorico.moveTo(x, y);
        } else {
          pathHistorico.lineTo(x, y);
        }
      }
      canvas.drawPath(pathHistorico, paintHistorico);
    }

    // Dibujar línea predicción (naranja punteado)
    if (predicciones.isNotEmpty) {
      final paintPrediccion = Paint()
        ..color = Colors.orange
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final startIdx = historicos.length - 1;
      final pathPrediccion = Path();

      // Empezar desde el último punto histórico
      if (historicos.isNotEmpty) {
        final lastHist = historicos.last;
        final x = startIdx * xStep;
        final y = size.height - (lastHist.value - minValue) * yScale;
        pathPrediccion.moveTo(x, y);
      }

      for (var i = 0; i < predicciones.length; i++) {
        final x = (startIdx + i + 1) * xStep;
        final y = size.height - (predicciones[i].value - minValue) * yScale;
        pathPrediccion.lineTo(x, y);
      }

      // Dibujar como línea punteada
      _drawDashedPath(canvas, pathPrediccion, paintPrediccion);
    }

    // Dibujar ejes
    final axisPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      axisPaint,
    );
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    var distance = 0.0;

    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance)!.position;
        distance += dashWidth;
        final end = metric.getTangentForOffset(distance)!.position;
        canvas.drawLine(start, end, paint);
        distance += dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(SimpleLineChartPainter oldDelegate) => true;
}
