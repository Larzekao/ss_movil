import 'package:ss_movil/features/products/infrastructure/dtos/brand_dto.dart';
import 'package:ss_movil/features/products/infrastructure/dtos/paged_dto.dart';

/// Remote DataSource para Brands (Infrastructure) - SOLO FIRMAS
abstract class BrandsRemoteDataSource {
  /// Lista marcas paginadas con filtros opcionales
  Future<PagedDto<BrandDto>> listBrands({
    int page = 1,
    int limit = 10,
    String? search,
    bool? isActive,
    String? orderBy,
  });

  /// Obtiene una marca por ID
  Future<BrandDto> getBrand(String id);

  /// Crea una nueva marca
  Future<BrandDto> createBrand(CreateBrandDto dto);

  /// Actualiza una marca existente
  Future<BrandDto> updateBrand(String id, UpdateBrandDto dto);

  /// Elimina una marca
  Future<void> deleteBrand(String id);

  /// Lista todas las marcas activas (sin paginación)
  Future<List<BrandDto>> getActiveBrands();
}

/// DTO para crear marca
class CreateBrandDto {
  final String nombre;
  final String? descripcion;
  final String? logo;
  final String? sitioWeb;

  const CreateBrandDto({
    required this.nombre,
    this.descripcion,
    this.logo,
    this.sitioWeb,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (logo != null) 'logo': logo,
      if (sitioWeb != null) 'sitio_web': sitioWeb,
    };
  }
}

/// DTO para actualizar marca
class UpdateBrandDto {
  final String? nombre;
  final String? descripcion;
  final String? logo;
  final String? sitioWeb;
  final bool? activo;

  const UpdateBrandDto({
    this.nombre,
    this.descripcion,
    this.logo,
    this.sitioWeb,
    this.activo,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (nombre != null) map['nombre'] = nombre;
    if (descripcion != null) map['descripcion'] = descripcion;
    if (logo != null) map['logo'] = logo;
    if (sitioWeb != null) map['sitio_web'] = sitioWeb;
    if (activo != null) map['activo'] = activo;
    return map;
  }
}
