import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ss_movil/features/reports/data/reports_api.dart';
import 'package:ss_movil/features/reports/data/reports_repository.dart';
import 'package:ss_movil/features/reports/domain/preview_response.dart';
import 'package:ss_movil/features/reports/domain/template_item.dart';

// Mock classes
class MockReportsApi extends Mock implements ReportsApi {}

void main() {
  late ReportsRepository repository;
  late MockReportsApi mockApi;

  setUp(() {
    mockApi = MockReportsApi();
    repository = ReportsRepository(mockApi);
  });

  group('ReportsRepository - preview', () {
    test('should return PreviewResponse when API call succeeds', () async {
      // Arrange
      const prompt = 'ventas 2025';
      final mockResponse = {
        'data': [
          {'id': 1, 'producto': 'Camisa', 'ventas': 100},
          {'id': 2, 'producto': 'Pantalón', 'ventas': 50},
        ],
        'total_rows': 2,
      };

      when(() => mockApi.preview(prompt)).thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.preview(prompt);

      // Assert
      expect(result, isA<PreviewResponse>());
      expect(result.totalRows, 2);
      expect(result.data.length, 2);
      expect(result.data[0].data['producto'], 'Camisa');
      expect(result.hasData, true);
      verify(() => mockApi.preview(prompt)).called(1);
    });

    test('should return empty PreviewResponse when no data', () async {
      // Arrange
      const prompt = 'no results';
      final mockResponse = {'data': <Map<String, dynamic>>[], 'total_rows': 0};

      when(() => mockApi.preview(prompt)).thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.preview(prompt);

      // Assert
      expect(result.totalRows, 0);
      expect(result.data.isEmpty, true);
      expect(result.hasData, false);
    });

    test('should throw exception when API call fails', () async {
      // Arrange
      const prompt = 'error prompt';
      when(() => mockApi.preview(prompt)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/reports/preview/'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/reports/preview/'),
            statusCode: 500,
          ),
        ),
      );

      // Act & Assert
      expect(() => repository.preview(prompt), throwsA(isA<DioException>()));
    });
  });

  group('ReportsRepository - generate', () {
    test(
      'should return file data with correct filename from headers',
      () async {
        // Arrange
        const prompt = 'reporte ventas';
        const format = 'pdf';
        const filename = 'Reporte_de_Ventas_20251111_120000.pdf';
        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        final mockResponse = Response<List<int>>(
          requestOptions: RequestOptions(path: '/api/reports/generate/'),
          data: bytes,
          statusCode: 200,
          headers: Headers.fromMap({
            'content-disposition': ['attachment; filename="$filename"'],
            'content-type': ['application/pdf'],
          }),
        );

        when(
          () => mockApi.generate(prompt, format: format),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.generate(prompt, format: format);

        // Assert
        expect(result, isNotNull);
        final (data, name, mimeType) = result!;
        expect(data, equals(bytes));
        expect(name, equals(filename));
        expect(mimeType, equals('application/pdf'));
        verify(() => mockApi.generate(prompt, format: format)).called(1);
      },
    );

    test(
      'should extract filename from Content-Disposition with various formats',
      () async {
        // Arrange
        const prompt = 'test';
        final bytes = Uint8List.fromList([1, 2, 3]);

        // Test different Content-Disposition formats
        final testCases = [
          {
            'header': 'attachment; filename="report.pdf"',
            'expected': 'report.pdf',
          },
          {
            'header': 'attachment; filename=report.pdf',
            'expected': 'report.pdf',
          },
          {'header': 'inline; filename="data.xlsx"', 'expected': 'data.xlsx'},
          {
            'header': 'attachment;filename="file with spaces.csv"',
            'expected': 'file with spaces.csv',
          },
        ];

        for (final testCase in testCases) {
          final mockResponse = Response<List<int>>(
            requestOptions: RequestOptions(path: '/api/reports/generate/'),
            data: bytes,
            statusCode: 200,
            headers: Headers.fromMap({
              'content-disposition': [testCase['header']!],
              'content-type': ['application/pdf'],
            }),
          );

          when(
            () => mockApi.generate(prompt, format: null),
          ).thenAnswer((_) async => mockResponse);

          // Act
          final result = await repository.generate(prompt);

          // Assert
          expect(result, isNotNull);
          final (_, name, _) = result!;
          expect(
            name,
            equals(testCase['expected']),
            reason: 'Failed for header: ${testCase['header']}',
          );
        }
      },
    );

    test(
      'should use fallback filename when Content-Disposition missing',
      () async {
        // Arrange
        const prompt = 'test';
        final bytes = Uint8List.fromList([1, 2, 3]);

        final mockResponse = Response<List<int>>(
          requestOptions: RequestOptions(path: '/api/reports/generate/'),
          data: bytes,
          statusCode: 200,
          headers: Headers.fromMap({
            'content-type': ['application/pdf'],
          }),
        );

        when(
          () => mockApi.generate(prompt, format: null),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.generate(prompt);

        // Assert
        expect(result, isNotNull);
        final (_, name, _) = result!;
        expect(name, startsWith('reporte_'));
        expect(name, endsWith('.pdf'));
      },
    );

    test('should return null when response data is null', () async {
      // Arrange
      const prompt = 'test';

      final mockResponse = Response<List<int>>(
        requestOptions: RequestOptions(path: '/api/reports/generate/'),
        data: null,
        statusCode: 200,
        headers: Headers.fromMap({
          'content-disposition': ['attachment; filename="report.pdf"'],
          'content-type': ['application/pdf'],
        }),
      );

      when(
        () => mockApi.generate(prompt, format: null),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.generate(prompt);

      // Assert
      expect(result, isNull);
    });

    test('should throw exception when API call fails', () async {
      // Arrange
      const prompt = 'error';
      when(() => mockApi.generate(prompt, format: null)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/reports/generate/'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/reports/generate/'),
            statusCode: 400,
          ),
        ),
      );

      // Act & Assert
      expect(() => repository.generate(prompt), throwsA(isA<DioException>()));
    });
  });

  group('ReportsRepository - templates', () {
    test(
      'should return list of TemplateItems when API call succeeds',
      () async {
        // Arrange
        final mockResponse = [
          {'label': 'Ventas mensuales', 'prompt': 'Ventas del mes actual'},
          {'label': 'Top productos', 'prompt': 'Top 10 productos más vendidos'},
        ];

        when(() => mockApi.templates()).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.templates();

        // Assert
        expect(result, isA<List<TemplateItem>>());
        expect(result.length, 2);
        expect(result[0].label, 'Ventas mensuales');
        expect(result[0].prompt, 'Ventas del mes actual');
        expect(result[1].label, 'Top productos');
        verify(() => mockApi.templates()).called(1);
      },
    );

    test('should return empty list when no templates available', () async {
      // Arrange
      final mockResponse = <Map<String, dynamic>>[];

      when(() => mockApi.templates()).thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.templates();

      // Assert
      expect(result.isEmpty, true);
    });

    test('should throw exception when API call fails', () async {
      // Arrange
      when(() => mockApi.templates()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/reports/templates/'),
        ),
      );

      // Act & Assert
      expect(() => repository.templates(), throwsA(isA<DioException>()));
    });
  });

  group('ReportsRepository - predefined', () {
    test('should return file data for predefined report', () async {
      // Arrange
      const reportType = 'sales_monthly';
      final params = {'month': 1, 'year': 2025};
      const format = 'xlsx';
      const filename = 'Ventas_Enero_2025.xlsx';
      final bytes = Uint8List.fromList([10, 20, 30]);

      final mockResponse = Response<List<int>>(
        requestOptions: RequestOptions(path: '/api/reports/predefined/'),
        data: bytes,
        statusCode: 200,
        headers: Headers.fromMap({
          'content-disposition': ['attachment; filename="$filename"'],
          'content-type': [
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ],
        }),
      );

      when(
        () => mockApi.predefined(
          reportType: reportType,
          params: params,
          format: format,
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.predefined(
        reportType: reportType,
        params: params,
        format: format,
      );

      // Assert
      expect(result, isNotNull);
      final (data, name, mimeType) = result!;
      expect(data, equals(bytes));
      expect(name, equals(filename));
      expect(
        mimeType,
        equals(
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ),
      );
    });

    test('should handle predefined report without params', () async {
      // Arrange
      const reportType = 'daily_summary';
      final bytes = Uint8List.fromList([5, 10, 15]);

      final mockResponse = Response<List<int>>(
        requestOptions: RequestOptions(path: '/api/reports/predefined/'),
        data: bytes,
        statusCode: 200,
        headers: Headers.fromMap({
          'content-disposition': ['attachment; filename="summary.pdf"'],
          'content-type': ['application/pdf'],
        }),
      );

      when(
        () => mockApi.predefined(
          reportType: reportType,
          params: null,
          format: null,
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.predefined(reportType: reportType);

      // Assert
      expect(result, isNotNull);
      verify(
        () => mockApi.predefined(
          reportType: reportType,
          params: null,
          format: null,
        ),
      ).called(1);
    });
  });
}
