import 'package:dio/dio.dart';

/// API client for reports endpoints
class ReportsApi {
  final Dio _dio;
  final String _baseUrl;

  ReportsApi(this._dio, {String? baseUrl}) : _baseUrl = baseUrl ?? '';

  /// Preview report data from natural language prompt
  ///
  /// POST /reports/preview/
  /// Body: { "prompt": "..." }
  /// Returns: JSON with data array and metadata
  Future<Map<String, dynamic>> preview(String prompt) async {
    final response = await _dio.post(
      '$_baseUrl/reports/preview/',
      data: {'prompt': prompt},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Generate report file from natural language prompt
  ///
  /// POST /reports/generate/
  /// Body: { "prompt": "...", "format": "pdf|excel|csv" }
  /// Returns: Binary file with headers
  Future<Response<List<int>>> generate(String prompt, {String? format}) async {
    final response = await _dio.post<List<int>>(
      '$_baseUrl/reports/generate/',
      data: {'prompt': prompt, if (format != null) 'format': format},
      options: Options(responseType: ResponseType.bytes),
    );
    return response;
  }

  /// Get available report templates
  ///
  /// GET /reports/templates/
  /// Returns: JSON array of template objects
  Future<List<dynamic>> templates() async {
    final response = await _dio.get('$_baseUrl/reports/templates/');
    return response.data as List<dynamic>;
  }

  /// Generate predefined report
  ///
  /// POST /reports/predefined/
  /// Body: { "report_type": "...", "params": {...}, "format": "pdf|excel|csv" }
  /// Returns: Binary file with headers
  Future<Response<List<int>>> predefined({
    required String reportType,
    Map<String, dynamic>? params,
    String? format,
  }) async {
    final response = await _dio.post<List<int>>(
      '$_baseUrl/reports/predefined/',
      data: {
        'report_type': reportType,
        if (params != null) 'params': params,
        if (format != null) 'format': format,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return response;
  }
}
