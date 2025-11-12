import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ss_movil/features/reports/data/reports_repository.dart';
import 'package:ss_movil/features/reports/domain/preview_response.dart';
import 'package:ss_movil/features/reports/domain/template_item.dart';
import 'package:ss_movil/features/reports/presentation/reports_page.dart';
import 'package:ss_movil/core/providers/app_providers.dart';

// Mock classes
class MockReportsRepository extends Mock implements ReportsRepository {}

void main() {
  late MockReportsRepository mockRepository;

  setUp(() {
    mockRepository = MockReportsRepository();
  });

  // Helper to create widget with providers
  Widget createTestWidget() {
    return ProviderScope(
      overrides: [reportsRepositoryProvider.overrideWithValue(mockRepository)],
      child: const MaterialApp(home: ReportsPage()),
    );
  }

  group('ReportsPage Widget Tests', () {
    testWidgets('should render all main UI elements', (tester) async {
      // Arrange
      when(
        () => mockRepository.templates(),
      ).thenAnswer((_) async => <TemplateItem>[]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Reportes'), findsOneWidget);
      expect(find.text('Generador de Reportes'), findsOneWidget);
      expect(
        find.text('Describe el reporte que necesitas en lenguaje natural'),
        findsOneWidget,
      );
      expect(find.text('Acciones rápidas'), findsOneWidget);
      expect(find.text('Formato:'), findsOneWidget);
      expect(find.text('Vista Previa'), findsOneWidget);
      expect(find.text('Generar y Descargar'), findsOneWidget);
    });

    testWidgets('should show quick action chips', (tester) async {
      // Arrange
      when(
        () => mockRepository.templates(),
      ).thenAnswer((_) async => <TemplateItem>[]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Default quick actions
      expect(find.text('Ventas 2025'), findsOneWidget);
      expect(find.text('Top 10 productos 2025'), findsOneWidget);
      expect(find.text('Clientes 2025'), findsOneWidget);
      expect(find.text('Pedidos pendientes'), findsOneWidget);
      expect(find.text('Stock bajo'), findsOneWidget);
    });

    testWidgets('should populate prompt when quick action chip is tapped', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockRepository.templates(),
      ).thenAnswer((_) async => <TemplateItem>[]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on 'Ventas 2025' chip
      await tester.tap(find.text('Ventas 2025'));
      await tester.pumpAndSettle();

      // Assert - TextField should contain the prompt
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Ventas totales del año 2025');
    });

    testWidgets('should load templates from backend', (tester) async {
      // Arrange
      final templates = [
        TemplateItem(label: 'Template 1', prompt: 'Prompt 1'),
        TemplateItem(label: 'Template 2', prompt: 'Prompt 2'),
      ];

      when(() => mockRepository.templates()).thenAnswer((_) async => templates);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Initial build
      await tester.pump(const Duration(seconds: 1)); // Wait for templates load
      await tester.pumpAndSettle();

      // Assert - Should show template chips
      expect(find.text('Template 1'), findsOneWidget);
      expect(find.text('Template 2'), findsOneWidget);
      verify(() => mockRepository.templates()).called(1);
    });

    testWidgets('should keep local templates when backend fails', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockRepository.templates(),
      ).thenThrow(Exception('Network error'));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Should still show default templates
      expect(find.text('Ventas 2025'), findsOneWidget);
      expect(find.text('Top 10 productos 2025'), findsOneWidget);
    });

    testWidgets('should show format dropdown with options', (tester) async {
      // Arrange
      when(
        () => mockRepository.templates(),
      ).thenAnswer((_) async => <TemplateItem>[]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('PDF'),
        findsNWidgets(2),
      ); // One in dropdown, one in menu
      expect(find.text('Excel (XLSX)'), findsOneWidget);
      expect(find.text('CSV'), findsOneWidget);
    });

    testWidgets('should disable buttons when prompt is empty', (tester) async {
      // Arrange
      when(
        () => mockRepository.templates(),
      ).thenAnswer((_) async => <TemplateItem>[]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Buttons should be disabled
      final previewButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Vista Previa'),
      );
      final generateButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Generar y Descargar'),
      );

      expect(previewButton.onPressed, isNull);
      expect(generateButton.onPressed, isNull);
    });

    testWidgets('should enable buttons when prompt has text', (tester) async {
      // Arrange
      when(
        () => mockRepository.templates(),
      ).thenAnswer((_) async => <TemplateItem>[]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter text in prompt field
      await tester.enterText(find.byType(TextField), 'Test prompt');
      await tester.pumpAndSettle();

      // Assert - Buttons should be enabled
      final previewButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Vista Previa'),
      );
      final generateButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Generar y Descargar'),
      );

      expect(previewButton.onPressed, isNotNull);
      expect(generateButton.onPressed, isNotNull);
    });

    testWidgets('should show loading indicator when preview is loading', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockRepository.templates(),
      ).thenAnswer((_) async => <TemplateItem>[]);
      when(() => mockRepository.preview(any())).thenAnswer(
        (_) async => Future.delayed(
          const Duration(seconds: 2),
          () => PreviewResponse.fromJson({'data': [], 'total_rows': 0}),
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter text and tap preview
      await tester.enterText(find.byType(TextField), 'Test prompt');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vista Previa'));
      await tester.pump(); // Start the async operation

      // Assert - Should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Procesando reporte...'), findsOneWidget);

      // Wait for completion
      await tester.pumpAndSettle();
    });

    testWidgets('should display preview data when preview succeeds', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockRepository.templates(),
      ).thenAnswer((_) async => <TemplateItem>[]);

      final previewData = PreviewResponse.fromJson({
        'data': [
          {'id': 1, 'producto': 'Camisa', 'precio': 100},
          {'id': 2, 'producto': 'Pantalón', 'precio': 150},
        ],
        'total_rows': 2,
      });

      when(
        () => mockRepository.preview('ventas 2025'),
      ).thenAnswer((_) async => previewData);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter text and tap preview
      await tester.enterText(find.byType(TextField), 'ventas 2025');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vista Previa'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('Vista Previa'),
        findsNWidgets(2),
      ); // Button + Card title
      expect(find.text('2 registros'), findsOneWidget);
      expect(find.text('Registro 1'), findsOneWidget);
      expect(find.text('Registro 2'), findsOneWidget);
      verify(() => mockRepository.preview('ventas 2025')).called(1);
    });

    testWidgets('should show error message when preview fails', (tester) async {
      // Arrange
      when(
        () => mockRepository.templates(),
      ).thenAnswer((_) async => <TemplateItem>[]);
      when(
        () => mockRepository.preview(any()),
      ).thenThrow(Exception('Network error'));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter text and tap preview
      await tester.enterText(find.byType(TextField), 'error prompt');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vista Previa'));
      await tester.pumpAndSettle();

      // Assert - Should show error card
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('should show "no data" message when preview returns empty', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockRepository.templates(),
      ).thenAnswer((_) async => <TemplateItem>[]);

      final emptyPreview = PreviewResponse.fromJson({
        'data': <Map<String, dynamic>>[],
        'total_rows': 0,
      });

      when(
        () => mockRepository.preview(any()),
      ).thenAnswer((_) async => emptyPreview);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'no results');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vista Previa'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('No se encontraron datos para este reporte'),
        findsOneWidget,
      );
    });

    testWidgets('should expand and show row details in preview', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockRepository.templates(),
      ).thenAnswer((_) async => <TemplateItem>[]);

      final previewData = PreviewResponse.fromJson({
        'data': [
          {'id': 1, 'producto': 'Camisa', 'precio': 100},
        ],
        'total_rows': 1,
      });

      when(
        () => mockRepository.preview(any()),
      ).thenAnswer((_) async => previewData);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vista Previa'));
      await tester.pumpAndSettle();

      // Expand the first row
      await tester.tap(find.text('Registro 1'));
      await tester.pumpAndSettle();

      // Assert - Should show row details
      expect(find.text('id:'), findsOneWidget);
      expect(find.text('producto:'), findsOneWidget);
      expect(find.text('precio:'), findsOneWidget);
      expect(find.text('Camisa'), findsOneWidget);
    });

    testWidgets('should call generate when generate button is tapped', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockRepository.templates(),
      ).thenAnswer((_) async => <TemplateItem>[]);

      final bytes = Uint8List.fromList([1, 2, 3]);
      when(
        () => mockRepository.generate(any(), format: any(named: 'format')),
      ).thenAnswer((_) async => (bytes, 'report.pdf', 'application/pdf'));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test report');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Generar y Descargar'));
      await tester.pump();

      // Assert - Should show loading snackbar
      expect(find.text('Generando reporte...'), findsOneWidget);

      // Wait for completion
      await tester.pumpAndSettle();

      // Verify repository was called
      verify(
        () => mockRepository.generate('test report', format: 'pdf'),
      ).called(1);
    });

    testWidgets('should maintain prompt text after preview', (tester) async {
      // Arrange
      when(
        () => mockRepository.templates(),
      ).thenAnswer((_) async => <TemplateItem>[]);

      final previewData = PreviewResponse.fromJson({
        'data': [
          {'id': 1, 'name': 'Test'},
        ],
        'total_rows': 1,
      });

      when(
        () => mockRepository.preview(any()),
      ).thenAnswer((_) async => previewData);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      const testPrompt = 'my test prompt';
      await tester.enterText(find.byType(TextField), testPrompt);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vista Previa'));
      await tester.pumpAndSettle();

      // Assert - Prompt should still be in the text field
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, testPrompt);
    });
  });
}
