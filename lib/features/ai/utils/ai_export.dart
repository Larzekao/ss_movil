import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../domain/ai_models.dart';

/// Utilidades para exportar y compartir datos de predicción IA
class AiExport {
  /// Exporta el forecast a CSV y permite abrirlo o compartirlo
  static Future<String> exportForecastCsv(AiForecastResponse forecast) async {
    try {
      // Generar contenido CSV
      final csvContent = _generateCsvContent(forecast);

      // Obtener directorio temporal
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/forecast_$timestamp.csv';

      // Escribir archivo
      final file = File(filePath);
      await file.writeAsString(csvContent);

      return filePath;
    } catch (e) {
      throw Exception('Error al exportar CSV: $e');
    }
  }

  /// Genera el contenido CSV del forecast
  static String _generateCsvContent(AiForecastResponse forecast) {
    final buffer = StringBuffer();

    // Header con información general
    buffer.writeln('# Predicción de Ventas - SmartSales365');
    buffer.writeln('# Generado: ${forecast.generatedAt}');
    if (forecast.modelUsed != null) {
      buffer.writeln('# Modelo: ${forecast.modelUsed}');
    }
    buffer.writeln();

    // KPIs
    if (forecast.kpis.isNotEmpty) {
      buffer.writeln('# Indicadores Clave');
      forecast.kpis.forEach((key, value) {
        buffer.writeln('# $key: $value');
      });
      buffer.writeln();
    }

    // Datos de predicción
    buffer.writeln('Fecha,Valor,Límite Inferior,Límite Superior,Tipo');

    for (final point in forecast.forecast) {
      final date = _formatDate(point.date);
      final value = point.value.toStringAsFixed(2);
      final lower = point.lowerBound?.toStringAsFixed(2) ?? '';
      final upper = point.upperBound?.toStringAsFixed(2) ?? '';
      final type = point.isHistorical ? 'Histórico' : 'Predicción';

      buffer.writeln('$date,$value,$lower,$upper,$type');
    }

    return buffer.toString();
  }

  /// Abre el archivo CSV con la app predeterminada del sistema
  static Future<void> openCsvFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }
    } catch (e) {
      throw Exception('Error al abrir archivo: $e');
    }
  }

  /// Comparte el archivo CSV
  static Future<void> shareCsvFile(String filePath) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        subject: 'Predicción de Ventas - SmartSales365',
        text: 'Datos de predicción de ventas generados por IA',
      );
    } catch (e) {
      throw Exception('Error al compartir archivo: $e');
    }
  }

  /// Captura un widget como imagen y lo comparte
  static Future<void> captureChartAndShare(GlobalKey chartKey) async {
    try {
      // Verificar que el widget tenga RenderRepaintBoundary
      final boundary =
          chartKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('No se pudo encontrar el gráfico para capturar');
      }

      // Capturar la imagen
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Error al convertir imagen');
      }

      // Guardar en archivo temporal
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/chart_$timestamp.png';

      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Compartir
      final xFile = XFile(filePath);
      await Share.shareXFiles(
        [xFile],
        subject: 'Gráfico de Predicción - SmartSales365',
        text: 'Gráfico de predicción de ventas generado por IA',
      );
    } catch (e) {
      throw Exception('Error al capturar y compartir gráfico: $e');
    }
  }

  /// Exporta y comparte el CSV en un solo paso
  static Future<void> exportAndShareCsv(AiForecastResponse forecast) async {
    final filePath = await exportForecastCsv(forecast);
    await shareCsvFile(filePath);
  }

  /// Exporta y abre el CSV en un solo paso
  static Future<void> exportAndOpenCsv(AiForecastResponse forecast) async {
    final filePath = await exportForecastCsv(forecast);
    await openCsvFile(filePath);
  }

  /// Formatea fecha para CSV (DD/MM/YYYY)
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Calcula el tamaño del archivo en formato legible
  static Future<String> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.length();

      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'Desconocido';
    }
  }
}
