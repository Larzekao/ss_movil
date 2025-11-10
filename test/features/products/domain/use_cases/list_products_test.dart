import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:ss_movil/features/products/domain/repositories/products_repository.dart';
import 'package:ss_movil/features/products/domain/entities/product.dart';
import 'package:ss_movil/features/products/domain/entities/category.dart';
import 'package:ss_movil/features/products/domain/entities/brand.dart';
import 'package:ss_movil/features/products/domain/value_objects/money.dart';
import 'package:ss_movil/core/errors/failures.dart';

// Mock del repositorio
class MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  late MockProductsRepository mockRepository;

  setUp(() {
    mockRepository = MockProductsRepository();
  });

  group('ProductsRepository - listProducts', () {
    final mockCategory = Category(
      id: 'cat1',
      nombre: 'Ropa',
      slug: 'ropa',
      descripcion: 'Categoría de ropa',
      activo: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final mockBrand = Brand(
      id: 'brand1',
      nombre: 'Nike',
      slug: 'nike',
      descripcion: 'Marca deportiva',
      activo: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final mockProduct = Product(
      id: 'prod1',
      nombre: 'Producto Test',
      descripcion: 'Descripción',
      precio: const Money(cantidad: 100.0, moneda: 'BOB'),
      stock: 10,
      codigo: 'PROD-001',
      slug: 'producto-test',
      categoria: mockCategory,
      marca: mockBrand,
      tallas: const [],
      imagenes: const [],
      material: 'Algodón',
      genero: null,
      temporada: null,
      color: 'Rojo',
      activo: true,
      metadatos: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final mockPagedResponse = PagedProducts(
      count: 1,
      results: [mockProduct],
      next: null,
      previous: null,
    );

    test(
      'debe retornar productos paginados cuando el repositorio tiene éxito',
      () async {
        // Arrange
        when(
          () => mockRepository.listProducts(),
        ).thenAnswer((_) async => Right(mockPagedResponse));

        // Act
        final result = await mockRepository.listProducts();

        // Assert
        expect(result, isA<Right<Failure, PagedProducts>>());
        result.fold((failure) => fail('No debería retornar failure'), (
          pagedProducts,
        ) {
          expect(pagedProducts.results.length, 1);
          expect(pagedProducts.count, 1);
          expect(pagedProducts.results.first.nombre, 'Producto Test');
        });
        verify(() => mockRepository.listProducts()).called(1);
      },
    );

    test('debe aplicar filtros de búsqueda correctamente', () async {
      // Arrange
      when(
        () => mockRepository.listProducts(search: 'Producto'),
      ).thenAnswer((_) async => Right(mockPagedResponse));

      // Act
      final result = await mockRepository.listProducts(search: 'Producto');

      // Assert
      expect(result, isA<Right<Failure, PagedProducts>>());
      verify(() => mockRepository.listProducts(search: 'Producto')).called(1);
    });

    test('debe aplicar filtros de precio mínimo y máximo', () async {
      // Arrange
      when(
        () => mockRepository.listProducts(minPrice: 50.0, maxPrice: 150.0),
      ).thenAnswer((_) async => Right(mockPagedResponse));

      // Act
      final result =
          await mockRepository.listProducts(minPrice: 50.0, maxPrice: 150.0);

      // Assert
      expect(result, isA<Right<Failure, PagedProducts>>());
      result.fold((failure) => fail('No debería retornar failure'), (
        pagedProducts,
      ) {
        // Verificar que el producto esté dentro del rango de precio
        expect(pagedProducts.results.first.precio.cantidad,
            greaterThanOrEqualTo(50.0));
        expect(pagedProducts.results.first.precio.cantidad,
            lessThanOrEqualTo(150.0));
      });
      verify(() => mockRepository.listProducts(minPrice: 50.0, maxPrice: 150.0))
          .called(1);
    });

    test('debe manejar paginación correctamente', () async {
      // Arrange
      final secondPageResponse = PagedProducts(
        count: 25,
        results: [mockProduct],
        next: 'http://api.example.com/products?page=3',
        previous: 'http://api.example.com/products?page=1',
      );
      when(
        () => mockRepository.listProducts(page: 2, limit: 10),
      ).thenAnswer((_) async => Right(secondPageResponse));

      // Act
      final result = await mockRepository.listProducts(page: 2, limit: 10);

      // Assert
      expect(result, isA<Right<Failure, PagedProducts>>());
      result.fold((failure) => fail('No debería retornar failure'), (
        pagedProducts,
      ) {
        expect(pagedProducts.count, 25);
        expect(pagedProducts.next, isNotNull);
        expect(pagedProducts.previous, isNotNull);
      });
      verify(() => mockRepository.listProducts(page: 2, limit: 10)).called(1);
    });

    test('debe filtrar por categoría', () async {
      // Arrange
      when(
        () => mockRepository.listProducts(categoryId: 'cat1'),
      ).thenAnswer((_) async => Right(mockPagedResponse));

      // Act
      final result = await mockRepository.listProducts(categoryId: 'cat1');

      // Assert
      expect(result, isA<Right<Failure, PagedProducts>>());
      result.fold((failure) => fail('No debería retornar failure'), (
        pagedProducts,
      ) {
        expect(pagedProducts.results.first.categoria.id, 'cat1');
      });
      verify(() => mockRepository.listProducts(categoryId: 'cat1')).called(1);
    });

    test('debe filtrar por marca', () async {
      // Arrange
      when(
        () => mockRepository.listProducts(brandId: 'brand1'),
      ).thenAnswer((_) async => Right(mockPagedResponse));

      // Act
      final result = await mockRepository.listProducts(brandId: 'brand1');

      // Assert
      expect(result, isA<Right<Failure, PagedProducts>>());
      result.fold((failure) => fail('No debería retornar failure'), (
        pagedProducts,
      ) {
        expect(pagedProducts.results.first.marca.id, 'brand1');
      });
      verify(() => mockRepository.listProducts(brandId: 'brand1')).called(1);
    });

    test('debe retornar ServerFailure cuando el repositorio falla', () async {
      // Arrange
      when(
        () => mockRepository.listProducts(),
      ).thenAnswer((_) async =>
          const Left(Failure.server(message: 'Error de servidor')));

      // Act
      final result = await mockRepository.listProducts();

      // Assert
      expect(result, isA<Left<Failure, PagedProducts>>());
      result.fold((failure) {
        expect(failure, isA<Failure>());
        failure.when(
          network: (message, statusCode) =>
              fail('No debería ser NetworkFailure'),
          auth: (message, statusCode) => fail('No debería ser AuthFailure'),
          server: (message, statusCode) => expect(message, 'Error de servidor'),
          validation: (message, errors) =>
              fail('No debería ser ValidationFailure'),
          unknown: (message) => fail('No debería ser UnknownFailure'),
        );
      }, (_) => fail('No debería retornar productos'));
      verify(() => mockRepository.listProducts()).called(1);
    });

    test('debe retornar lista vacía cuando no hay productos', () async {
      // Arrange
      const emptyResponse = PagedProducts(
        count: 0,
        results: [],
        next: null,
        previous: null,
      );
      when(
        () => mockRepository.listProducts(),
      ).thenAnswer((_) async => const Right(emptyResponse));

      // Act
      final result = await mockRepository.listProducts();

      // Assert
      expect(result, isA<Right<Failure, PagedProducts>>());
      result.fold((failure) => fail('No debería retornar failure'), (
        pagedProducts,
      ) {
        expect(pagedProducts.results, isEmpty);
        expect(pagedProducts.count, 0);
      });
      verify(() => mockRepository.listProducts()).called(1);
    });

    test('debe combinar múltiples filtros correctamente', () async {
      // Arrange
      when(
        () => mockRepository.listProducts(
          search: 'Nike',
          categoryId: 'cat1',
          brandId: 'brand1',
          minPrice: 50.0,
          maxPrice: 200.0,
          isActive: true,
          page: 1,
          limit: 10,
        ),
      ).thenAnswer((_) async => Right(mockPagedResponse));

      // Act
      final result = await mockRepository.listProducts(
        search: 'Nike',
        categoryId: 'cat1',
        brandId: 'brand1',
        minPrice: 50.0,
        maxPrice: 200.0,
        isActive: true,
        page: 1,
        limit: 10,
      );

      // Assert
      expect(result, isA<Right<Failure, PagedProducts>>());
      verify(
        () => mockRepository.listProducts(
          search: 'Nike',
          categoryId: 'cat1',
          brandId: 'brand1',
          minPrice: 50.0,
          maxPrice: 200.0,
          isActive: true,
          page: 1,
          limit: 10,
        ),
      ).called(1);
    });
  });
}
