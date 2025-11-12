import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../domain/preview_response.dart';
import '../domain/template_item.dart';
import 'reports_api.dart';

/// Repository for reports data operations
class ReportsRepository {
  final ReportsApi _api;

  ReportsRepository(this._api);

  /// Preview report data from natural language prompt
  ///
  /// Throws [DioException] on network errors
  Future<PreviewResponse> preview(String prompt) async {
    final json = await _api.preview(prompt);
    return PreviewResponse.fromJson(json);
  }

  /// Generate report file from natural language prompt
  ///
  /// Returns tuple: (bytes, filename, mimeType)
  /// Throws [DioException] on network errors
  Future<(Uint8List, String, String)> generate(
    String prompt, {
    String? format,
  }) async {
    final response = await _api.generate(prompt, format: format);
    return _parseFileResponse(response);
  }

  /// Get available report templates
  ///
  /// Throws [DioException] on network errors
  Future<List<TemplateItem>> templates() async {
    final jsonList = await _api.templates();
    return jsonList
        .map((json) => TemplateItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Generate predefined report
  ///
  /// Returns tuple: (bytes, filename, mimeType)
  /// Throws [DioException] on network errors
  Future<(Uint8List, String, String)> predefined({
    required String reportType,
    Map<String, dynamic>? params,
    String? format,
  }) async {
    final response = await _api.predefined(
      reportType: reportType,
      params: params,
      format: format,
    );
    return _parseFileResponse(response);
  }

  /// Parse file response extracting bytes, filename, and mime type
  ///
  /// Extracts filename from Content-Disposition header
  /// Extracts mime type from Content-Type header
  (Uint8List, String, String) _parseFileResponse(Response<List<int>> response) {
    // Get bytes
    final bytes = Uint8List.fromList(response.data ?? []);

    // Extract filename from Content-Disposition header
    String filename = 'report';
    final contentDisposition = response.headers.value('content-disposition');
    if (contentDisposition != null) {
      filename = _extractFilename(contentDisposition);
    }

    // Extract mime type from Content-Type header
    String mimeType = 'application/octet-stream';
    final contentType = response.headers.value('content-type');
    if (contentType != null) {
      mimeType = contentType.split(';').first.trim();
    }

    return (bytes, filename, mimeType);
  }

  /// Extract filename from Content-Disposition header
  ///
  /// Handles formats:
  /// - attachment; filename="report.pdf"
  /// - attachment; filename=report.pdf
  /// - inline; filename*=UTF-8''report.pdf
  String _extractFilename(String contentDisposition) {
    // Try filename*= first (RFC 5987)
    final filenameStarMatch = RegExp(
      r"filename\*=(?:UTF-8'')?([^;]+)",
    ).firstMatch(contentDisposition);
    if (filenameStarMatch != null) {
      return Uri.decodeComponent(filenameStarMatch.group(1)!.trim());
    }

    // Try filename= with quotes
    final filenameQuotedMatch = RegExp(
      r'filename="([^"]+)"',
    ).firstMatch(contentDisposition);
    if (filenameQuotedMatch != null) {
      return filenameQuotedMatch.group(1)!.trim();
    }

    // Try filename= without quotes
    final filenameMatch = RegExp(
      r'filename=([^;]+)',
    ).firstMatch(contentDisposition);
    if (filenameMatch != null) {
      return filenameMatch.group(1)!.trim();
    }

    // Fallback
    return 'report';
  }
}
