import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/preview_response.dart';
import '../domain/template_item.dart';
import 'reports_controller.dart';
import 'voice_controller.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  final _promptController = TextEditingController();
  String _selectedFormat = 'pdf';

  // Quick action templates (fallback local)
  List<({String label, String prompt})> _quickActions = [
    (label: 'Ventas 2025', prompt: 'Ventas totales del año 2025'),
    (
      label: 'Top 10 productos 2025',
      prompt: 'Top 10 productos más vendidos en 2025',
    ),
    (
      label: 'Clientes 2025',
      prompt: 'Lista de todos los clientes registrados en 2025',
    ),
    (label: 'Pedidos pendientes', prompt: 'Pedidos con estado pendiente'),
    (label: 'Stock bajo', prompt: 'Productos con stock menor a 10 unidades'),
  ];

  @override
  void initState() {
    super.initState();
    // Cargar plantillas desde backend sin bloquear UI
    _loadTemplatesFromBackend();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  /// Carga plantillas desde backend de forma asíncrona
  /// Mantiene fallback local si falla
  Future<void> _loadTemplatesFromBackend() async {
    try {
      final templates = await ref
          .read(reportsControllerProvider.notifier)
          .getTemplates()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => <TemplateItem>[],
          );

      if (templates.isNotEmpty && mounted) {
        setState(() {
          // Filtrar plantillas con datos válidos
          _quickActions = templates
              .where((t) => t.label.isNotEmpty && t.prompt.isNotEmpty)
              .map((t) => (label: t.label, prompt: t.prompt))
              .toList();
        });
      }
    } catch (e) {
      // Silenciosamente mantener fallback local
      // No mostrar error al usuario, las plantillas locales funcionan
      // Solo registrar el error en debug
      assert(() {
        // ignore: avoid_print
        print('[ReportsPage] Error cargando plantillas: $e');
        return true;
      }());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        title: const Text('Reportes'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy, color: Colors.deepPurple),
            onPressed: () {
              // Navegar a IA Dashboard
              context.go('/admin/ai');
            },
            tooltip: 'Dashboard IA',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card - Reportes Dinámicos
            _buildHeaderCard(),
            const SizedBox(height: 24),

            // Quick actions
            _buildQuickActions(),
            const SizedBox(height: 24),

            // Main Generator Card
            _buildGeneratorCard(state),
            const SizedBox(height: 24),

            // State-based content
            _buildStateContent(state),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.blue[500]!],
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assessment,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reportes Dinámicos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Genera reportes personalizados usando lenguaje natural',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratorCard(ReportsState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Generar Reporte',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Describe el reporte que necesitas',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Prompt input
            _buildPromptInput(),
            const SizedBox(height: 20),

            // Format selector
            _buildFormatSelector(),
            const SizedBox(height: 24),

            // Action buttons
            _buildActionButtons(state),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.flash_on, color: Colors.orange, size: 24),
                SizedBox(width: 8),
                Text(
                  'Reportes Predeterminados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Haz clic para generar reportes comunes al instante',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _quickActions.map((action) {
                return _buildQuickActionChip(action);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(({String label, String prompt}) action) {
    // Determinar color según el tipo de reporte
    Color chipColor;
    IconData chipIcon;

    if (action.label.toLowerCase().contains('ventas')) {
      chipColor = Colors.green[100]!;
      chipIcon = Icons.attach_money;
    } else if (action.label.toLowerCase().contains('productos')) {
      chipColor = Colors.purple[100]!;
      chipIcon = Icons.inventory_2;
    } else if (action.label.toLowerCase().contains('clientes')) {
      chipColor = Colors.blue[100]!;
      chipIcon = Icons.people;
    } else if (action.label.toLowerCase().contains('pedidos')) {
      chipColor = Colors.orange[100]!;
      chipIcon = Icons.receipt_long;
    } else {
      chipColor = Colors.grey[200]!;
      chipIcon = Icons.description;
    }

    return InkWell(
      onTap: () {
        _promptController.text = action.prompt;
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: chipColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(chipIcon, size: 18, color: Colors.black87),
            const SizedBox(width: 8),
            Text(
              action.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptInput() {
    final voiceState = ref.watch(voiceControllerProvider);
    final voiceController = ref.read(voiceControllerProvider.notifier);

    // Actualizar el TextField cuando cambia el texto (parcial o final)
    ref.listen<VoiceState>(voiceControllerProvider, (previous, next) {
      // Actualizar con texto parcial en tiempo real
      if (next.partialText.isNotEmpty) {
        final currentText = _promptController.text.trim();
        final baseText = previous?.finalText ?? '';

        if (currentText.startsWith(baseText)) {
          // Reemplazar solo la parte parcial
          final newText = baseText.isEmpty
              ? next.partialText
              : '$baseText ${next.partialText}';
          _promptController.text = newText;
          _promptController.selection = TextSelection.fromPosition(
            TextPosition(offset: newText.length),
          );
        }
      }

      // Actualizar con texto final
      if (next.finalText.isNotEmpty && next.finalText != previous?.finalText) {
        final currentText = _promptController.text.trim();
        final newText = currentText.isEmpty
            ? next.finalText
            : '$currentText ${next.finalText}';
        _promptController.text = newText;
        _promptController.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );
      }

      // Mostrar errores en SnackBar
      if (next.hasError && next.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(next.errorMessage!)),
              ],
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () => voiceController.clearError(),
            ),
          ),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _promptController,
            maxLines: 4,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Ej: "Reporte de ventas del año 2025 en PDF"',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  Icons.description_outlined,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(
                    voiceState.isListening ? Icons.mic : Icons.mic_none,
                    color: voiceState.isListening
                        ? Colors.red
                        : Colors.grey[600],
                    size: 28,
                  ),
                  onPressed: () async {
                    if (voiceState.isListening) {
                      await voiceController.stop();
                    } else {
                      if (!voiceState.isAvailable || !voiceState.isReady) {
                        await voiceController.init();
                      }
                      if (voiceState.isReady || voiceState.isAvailable) {
                        await voiceController.startListening();
                      }
                    }
                  },
                  tooltip: voiceState.isListening
                      ? 'Detener dictado'
                      : 'Dictar por voz',
                ),
              ),
            ),
          ),
        ),
        // Indicador de estado de voz - Pill flotante
        if (voiceState.isListening)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red[700],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mic, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Escuchando...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Hint text
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 4),
          child: Text(
            'Puedes usar texto o voz. Especifica el formato en el prompt (PDF, Excel o CSV).',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.file_download, color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          const Text(
            'Formato:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButton<String>(
                value: _selectedFormat,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down),
                items: const [
                  DropdownMenuItem(
                    value: 'pdf',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('PDF'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'xlsx',
                    child: Row(
                      children: [
                        Icon(Icons.table_chart, size: 18, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Excel (XLSX)'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'csv',
                    child: Row(
                      children: [
                        Icon(
                          Icons.text_snippet,
                          size: 18,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Text('CSV'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedFormat = value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ReportsState state) {
    final isLoading = state is ReportsLoading;
    final prompt = _promptController.text.trim();
    final hasPrompt = prompt.isNotEmpty;

    return Column(
      children: [
        // Vista Previa button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isLoading || !hasPrompt ? null : _handlePreview,
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Vista Previa'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.blue[700]!, width: 2),
              foregroundColor: Colors.blue[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Generar y Descargar button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading || !hasPrompt ? null : _handleGenerate,
            icon: const Icon(Icons.download_rounded, size: 22),
            label: const Text(
              'Generar y Descargar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStateContent(ReportsState state) {
    return switch (state) {
      ReportsLoading() => _buildLoadingState(),
      ReportsPreviewOk() => _buildPreviewState(state.preview),
      ReportsError() => _buildErrorState(state.message),
      ReportsIdle() => const SizedBox.shrink(),
    };
  }

  Widget _buildLoadingState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(40.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Procesando reporte...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Esto puede tomar unos segundos',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewState(PreviewResponse preview) {
    if (!preview.hasData) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.orange[700]),
              const SizedBox(height: 16),
              const Text(
                'No se encontraron datos para este reporte',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    final columns = preview.columnNames;
    final rows = preview.data.take(20).toList(); // Limit to 20 rows

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.preview, color: Colors.blue, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Vista Previa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${preview.totalRows} registros',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (preview.totalRows > 20)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.amber[900],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mostrando los primeros 20 de ${preview.totalRows} registros',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: ListView.builder(
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final row = rows[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      title: Text(
                        'Registro ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        radius: 18,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: columns.map((column) {
                              final value =
                                  row.data[column]?.toString() ?? 'N/A';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 120,
                                      child: Text(
                                        '$column:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        value,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.red[50],
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red[200]!, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Error',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(message, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePreview() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    await ref.read(reportsControllerProvider.notifier).doPreview(prompt);

    // Show error if state changed to error
    if (mounted) {
      final state = ref.read(reportsControllerProvider);
      if (state is ReportsError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(state.message)),
              ],
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
        // Mantener el prompt ingresado para corrección
      }
    }
  }

  Future<void> _handleGenerate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    // Show loading snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Generando reporte...'),
            ],
          ),
          duration: Duration(seconds: 120),
        ),
      );
    }

    final result = await ref
        .read(reportsControllerProvider.notifier)
        .doGenerate(prompt, format: _selectedFormat);

    // Hide loading snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    if (result == null) {
      // Show error message from state
      if (mounted) {
        final state = ref.read(reportsControllerProvider);
        if (state is ReportsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.red[700],
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: 'REINTENTAR',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _handleGenerate();
                },
              ),
            ),
          );
          // Mantener el prompt ingresado para corrección
        }
      }
      return;
    }

    final (bytes, filename, mimeType) = result;

    // Validate result
    if (bytes.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('El archivo generado está vacío.')),
              ],
            ),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Save file
    try {
      final tempDir = await getTemporaryDirectory();
      final sanitizedFilename = filename.isNotEmpty
          ? filename
          : 'reporte_${DateTime.now().millisecondsSinceEpoch}.${_selectedFormat}';

      final file = File('${tempDir.path}/$sanitizedFilename');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Reporte guardado: $sanitizedFilename')),
              ],
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'VER UBICACIÓN',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _showFileLocationDialog(file.path);
              },
            ),
          ),
        );
      }

      // Auto-show file location dialog
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          await _showFileLocationDialog(file.path);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error al guardar archivo: $e')),
              ],
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _showFileLocationDialog(String filePath) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 12),
            Text('Reporte Generado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('El reporte se guardó exitosamente en:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                filePath,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
