import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/entities/brand.dart';

/// Repository contract para Brands (Domain)
abstract class BrandsRepository {
  /// Lista marcas paginadas con filtros opcionales
  Future<Either<Failure, PagedBrands>> listBrands({
    int page = 1,
    int limit = 10,
    String? search,
    bool? isActive,
    String? orderBy,
  });

  /// Obtiene una marca por ID
  Future<Either<Failure, Brand>> getBrand(String id);

  /// Crea una nueva marca
  Future<Either<Failure, Brand>> createBrand(CreateBrandRequest request);

  /// Actualiza una marca existente
  Future<Either<Failure, Brand>> updateBrand(
    String id,
    UpdateBrandRequest request,
  );

  /// Elimina una marca
  Future<Either<Failure, void>> deleteBrand(String id);

  /// Lista todas las marcas activas (sin paginación)
  Future<Either<Failure, List<Brand>>> getActiveBrands();
}

/// Resultado paginado de marcas
class PagedBrands {
  final int count;
  final String? next;
  final String? previous;
  final List<Brand> results;

  const PagedBrands({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });
}

/// Request para crear marca
class CreateBrandRequest {
  final String nombre;
  final String? descripcion;
  final String? logo;
  final String? sitioWeb;

  const CreateBrandRequest({
    required this.nombre,
    this.descripcion,
    this.logo,
    this.sitioWeb,
  });
}

/// Request para actualizar marca
class UpdateBrandRequest {
  final String? nombre;
  final String? descripcion;
  final String? logo;
  final String? sitioWeb;
  final bool? activo;

  const UpdateBrandRequest({
    this.nombre,
    this.descripcion,
    this.logo,
    this.sitioWeb,
    this.activo,
  });
}
