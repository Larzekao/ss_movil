/// Preview row model for report data
class PreviewRow {
  final Map<String, dynamic> data;

  PreviewRow(this.data);

  factory PreviewRow.fromJson(Map<String, dynamic> json) {
    return PreviewRow(json);
  }

  Map<String, dynamic> toJson() => data;
}

/// Preview response model from reports API
class PreviewResponse {
  final List<PreviewRow> data;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? config;
  final int totalRows;

  PreviewResponse({
    required this.data,
    this.metadata,
    this.config,
    required this.totalRows,
  });

  factory PreviewResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    final rows = dataList
        .map((item) => PreviewRow.fromJson(item as Map<String, dynamic>))
        .toList();

    // Parse total_rows with fallback to data length
    final totalRows =
        json['total_rows'] as int? ?? json['totalRows'] as int? ?? rows.length;

    return PreviewResponse(
      data: rows,
      metadata: json['metadata'] as Map<String, dynamic>?,
      config: json['config'] as Map<String, dynamic>?,
      totalRows: totalRows,
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data.map((row) => row.toJson()).toList(),
    if (metadata != null) 'metadata': metadata,
    if (config != null) 'config': config,
    'total_rows': totalRows,
  };

  /// Get column names from first row or metadata
  List<String> get columnNames {
    if (data.isEmpty) return [];

    // Try to get from metadata first
    if (metadata != null && metadata!['columns'] != null) {
      return (metadata!['columns'] as List<dynamic>)
          .map((col) => col.toString())
          .toList();
    }

    // Fallback to keys from first row
    return data.first.data.keys.toList();
  }

  /// Check if response has data
  bool get hasData => data.isNotEmpty;

  /// Get row count
  int get rowCount => data.length;
}
