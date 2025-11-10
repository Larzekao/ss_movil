import 'package:dio/dio.dart';
import 'package:ss_movil/features/products/infrastructure/dtos/size_dto.dart';
import 'package:ss_movil/features/products/infrastructure/dtos/paged_dto.dart';
import 'sizes_remote_ds.dart';

class SizesRemoteDataSourceImpl implements SizesRemoteDataSource {
  final Dio _dio;

  SizesRemoteDataSourceImpl(this._dio);

  @override
  Future<PagedDto<SizeDto>> listSizes({
    int page = 1,
    int limit = 10,
    String? search,
    bool? isActive,
    String? orderBy,
  }) async {
    try {
      final params = {
        'page': page,
        'limit': limit,
        if (search != null) 'search': search,
        if (isActive != null) 'is_active': isActive,
        if (orderBy != null) 'order_by': orderBy,
      };

      final response = await _dio.get(
        '/products/tallas/',
        queryParameters: params,
      );

      return PagedDto.fromJson(
        response.data,
        (item) => SizeDto.fromJson(item as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SizeDto>> getActiveSizes() async {
    try {
      final response = await _dio.get(
        '/products/tallas/',
        queryParameters: {'is_active': true},
      );

      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>?;

      if (results == null) {
        return [];
      }

      return results
          .map((item) => SizeDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
