import 'package:dartz/dartz.dart';
import 'package:ss_movil/core/errors/failures.dart';
import 'package:ss_movil/features/products/domain/entities/brand.dart';
import 'package:ss_movil/features/products/domain/repositories/brands_repository.dart';

/// Use case para crear una nueva marca
class CreateBrand {
  final BrandsRepository _repository;

  const CreateBrand(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, Brand>> call(CreateBrandRequest request) {
    // Validaciones básicas
    if (request.nombre.isEmpty) {
      return Future.value(
        const Left(Failure.validation(message: 'Nombre de la marca requerido')),
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

    return _repository.createBrand(request);
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
