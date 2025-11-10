import 'package:dio/dio.dart';
import 'package:ss_movil/features/products/infrastructure/dtos/brand_dto.dart';
import 'package:ss_movil/features/products/infrastructure/dtos/paged_dto.dart';
import 'brands_remote_ds.dart';

class BrandsRemoteDataSourceImpl implements BrandsRemoteDataSource {
  final Dio _dio;

  BrandsRemoteDataSourceImpl(this._dio);

  @override
  Future<PagedDto<BrandDto>> listBrands({
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
        '/products/marcas/',
        queryParameters: params,
      );

      return PagedDto.fromJson(
        response.data,
        (item) => BrandDto.fromJson(item as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BrandDto> getBrand(String id) async {
    try {
      final response = await _dio.get('/products/marcas/$id/');
      return BrandDto.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BrandDto> createBrand(CreateBrandDto dto) async {
    try {
      final response = await _dio.post(
        '/products/marcas/',
        data: dto.toJson(),
      );
      return BrandDto.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BrandDto> updateBrand(String id, UpdateBrandDto dto) async {
    try {
      final response = await _dio.put(
        '/products/marcas/$id/',
        data: dto.toJson(),
      );
      return BrandDto.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteBrand(String id) async {
    try {
      await _dio.delete('/products/marcas/$id/');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BrandDto>> getActiveBrands() async {
    try {
      final response = await _dio.get(
        '/products/marcas/',
        queryParameters: {'is_active': true},
      );

      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>?;

      if (results == null) {
        return [];
      }

      return results
          .map((item) => BrandDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
