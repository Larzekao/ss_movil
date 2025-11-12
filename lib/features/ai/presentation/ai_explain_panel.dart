import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Panel de explicación IA para preview de reportes
///
/// Este panel puede recibir JSON de un preview de reporte y mostrar
/// una explicación generada por IA (si el backend lo soporta) o
/// una explicación de fallback basada en el contenido.
class AiExplainPanel extends ConsumerStatefulWidget {
  final Map<String, dynamic>? previewJson;
  final VoidCallback? onClose;

  const AiExplainPanel({super.key, this.previewJson, this.onClose});

  @override
  ConsumerState<AiExplainPanel> createState() => _AiExplainPanelState();
}

class _AiExplainPanelState extends ConsumerState<AiExplainPanel> {
  bool _isLoading = false;
  String? _explanation;
  List<String> _keyFindings = [];

  @override
  void initState() {
    super.initState();
    if (widget.previewJson != null) {
      _generateExplanation();
    }
  }

  Future<void> _generateExplanation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Si el backend implementa endpoint de explicación IA:
      // final explanation = await ref
      //     .read(aiControllerProvider.notifier)
      //     .explainPreview(widget.previewJson!);

      // Por ahora usamos análisis local del JSON
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Simular procesamiento

      final analysis = _analyzePreview(widget.previewJson!);

      setState(() {
        _explanation = analysis['explanation'];
        _keyFindings = List<String>.from(analysis['findings']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _explanation = 'No se pudo generar la explicación. Error: $e';
        _keyFindings = ['Revisa los datos manualmente'];
        _isLoading = false;
      });
    }
  }

  /// Analiza el preview JSON y genera explicación de fallback
  Map<String, dynamic> _analyzePreview(Map<String, dynamic> preview) {
    final StringBuffer explanation = StringBuffer();
    final List<String> findings = [];

    // Analizar tipo de reporte
    final reportType = preview['report_type'] ?? 'desconocido';
    explanation.write('Este reporte de tipo "$reportType" muestra ');

    // Analizar datos según estructura
    if (preview.containsKey('data') && preview['data'] is List) {
      final data = preview['data'] as List;
      explanation.write('${data.length} registros. ');
      findings.add('Total de registros: ${data.length}');

      // Buscar campos numéricos para análisis
      if (data.isNotEmpty && data.first is Map) {
        final firstRecord = data.first as Map<String, dynamic>;

        // Analizar campos monetarios
        final monetaryFields = firstRecord.keys
            .where(
              (key) =>
                  key.toLowerCase().contains('total') ||
                  key.toLowerCase().contains('precio') ||
                  key.toLowerCase().contains('monto') ||
                  key.toLowerCase().contains('venta'),
            )
            .toList();

        if (monetaryFields.isNotEmpty) {
          for (final field in monetaryFields) {
            try {
              final values = data
                  .map((record) => (record as Map)[field])
                  .where((v) => v != null && v is num)
                  .map((v) => (v as num).toDouble())
                  .toList();

              if (values.isNotEmpty) {
                final total = values.reduce((a, b) => a + b);
                final average = total / values.length;
                final max = values.reduce((a, b) => a > b ? a : b);
                final min = values.reduce((a, b) => a < b ? a : b);

                findings.add(
                  '$field: Total Bs. ${total.toStringAsFixed(2)}, '
                  'Promedio Bs. ${average.toStringAsFixed(2)}',
                );

                if (max - min > average * 0.5) {
                  findings.add(
                    'Hay alta variación en $field (${((max - min) / average * 100).toStringAsFixed(0)}%)',
                  );
                }
              }
            } catch (e) {
              // Ignorar campos que no se puedan analizar
            }
          }
        }

        // Buscar productos/categorías más frecuentes
        final nameFields = firstRecord.keys
            .where(
              (key) =>
                  key.toLowerCase().contains('nombre') ||
                  key.toLowerCase().contains('producto') ||
                  key.toLowerCase().contains('categoria'),
            )
            .toList();

        if (nameFields.isNotEmpty) {
          final field = nameFields.first;
          final frequency = <String, int>{};

          for (final record in data) {
            final value = (record as Map)[field]?.toString();
            if (value != null) {
              frequency[value] = (frequency[value] ?? 0) + 1;
            }
          }

          final sortedItems = frequency.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          if (sortedItems.length > 1) {
            final top = sortedItems.take(3).toList();
            findings.add(
              'Top 3 más frecuentes: ${top.map((e) => '${e.key} (${e.value})').join(', ')}',
            );
          }
        }
      }
    }

    // Analizar totales si existen
    if (preview.containsKey('totales')) {
      final totales = preview['totales'];
      if (totales is Map) {
        totales.forEach((key, value) {
          if (value is num) {
            findings.add('$key: Bs. ${value.toStringAsFixed(2)}');
          }
        });
      }
    }

    // Conclusión
    if (findings.isEmpty) {
      explanation.write(
        'No hay explicación automática disponible. '
        'Revisa totales, variaciones y productos top manualmente.',
      );
      findings.add('Revisa los datos en la vista de preview');
    } else {
      explanation.write(
        'Los datos muestran información relevante para análisis.',
      );
    }

    return {'explanation': explanation.toString(), 'findings': findings};
  }

  @override
  Widget build(BuildContext context) {
    if (widget.previewJson == null) {
      return _buildNoDataState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[700]!, Colors.purple[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Explicación IA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (widget.onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: widget.onClose,
                  ),
              ],
            ),
          ),

          // Content
          _isLoading ? _buildLoadingState() : _buildExplanationContent(),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay datos para explicar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Genera un preview de reporte primero',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.purple[700]),
          const SizedBox(height: 16),
          const Text('Analizando datos...', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildExplanationContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Explicación principal
          if (_explanation != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.psychology, color: Colors.purple[700], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _explanation!,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Hallazgos clave
          if (_keyFindings.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[700], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Hallazgos Clave',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._keyFindings.map((finding) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.purple[700],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        finding,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
          ],

          // Botón de acción
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onClose,
              icon: const Icon(Icons.check),
              label: const Text('Entendido'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Método auxiliar para cuando se llame desde otros widgets
  /// Muestra el panel como BottomSheet
  static void show(
    BuildContext context, {
    required Map<String, dynamic> previewJson,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => AiExplainPanel(
          previewJson: previewJson,
          onClose: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
