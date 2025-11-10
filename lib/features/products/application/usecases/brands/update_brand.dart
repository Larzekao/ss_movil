import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/entities/brand.dart';
import 'package:ss_movil/features/products/domain/repositories/brands_repository.dart';

/// Use case para actualizar una marca existente
class UpdateBrand {
  final BrandsRepository _repository;

  const UpdateBrand(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, Brand>> call(
    String brandId,
    UpdateBrandRequest request,
  ) {
    if (brandId.isEmpty) {
      return Future.value(
        const Left(Failure.validation(message: 'ID de marca requerido')),
      );
    }

    // Validaciones condicionales
    if (request.nombre != null && request.nombre!.isEmpty) {
      return Future.value(
        const Left(Failure.validation(message: 'Nombre no puede estar vacío')),
      );
    }

    // Validación de URL si se proporciona sitio web
    if (request.sitioWeb != null &&
        request.sitioWeb!.isNotEmpty &&
        !_isValidUrl(request.sitioWeb!)) {
      return Future.value(
        const Left(Failure.validation(message: 'URL del sitio web inválida')),
      );
    }

    return _repository.updateBrand(brandId, request);
  }

  /// Valida si una URL tiene formato correcto
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
