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
    test(
      'debe retornar productos paginados cuando la llamada tiene éxito',
      () async {
        // Arrange
        final mockCategory = Category(
          id: 'cat1',
          nombre: 'Ropa',
          slug: 'ropa',
          activo: true,
          createdAt: DateTime(2024, 1, 1),
        );

        final mockBrand = Brand(
          id: 'brand1',
          nombre: 'Nike',
          slug: 'nike',
          activo: true,
          createdAt: DateTime(2024, 1, 1),
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
          activo: true,
          createdAt: DateTime(2024, 1, 1),
        );

        final mockPagedResponse = PagedProducts(
          count: 1,
          results: [mockProduct],
          next: null,
          previous: null,
        );

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

    test('debe retornar ServerFailure cuando falla la llamada', () async {
      // Arrange
      when(() => mockRepository.listProducts()).thenAnswer(
        (_) async => const Left(Failure.server(message: 'Error de servidor')),
      );

      // Act
      final result = await mockRepository.listProducts();

      // Assert
      expect(result, isA<Left<Failure, PagedProducts>>());
      result.fold((failure) {
        expect(failure, isA<Failure>());
        failure.when(
          network: (message, _) => fail('Should not be network failure'),
          auth: (message, _) => fail('Should not be auth failure'),
          server: (message, _) => expect(message, 'Error de servidor'),
          validation: (message, _) => fail('Should not be validation failure'),
          notFound: (message, _) => fail('Should not be notFound failure'),
          unknown: (message) => fail('Should not be unknown failure'),
        );
      }, (pagedProducts) => fail('No debería retornar productos'));
      verify(() => mockRepository.listProducts()).called(1);
    });

    test('debe aplicar filtros de búsqueda correctamente', () async {
      // Arrange
      final mockCategory = Category(
        id: 'cat1',
        nombre: 'Ropa',
        slug: 'ropa',
        activo: true,
        createdAt: DateTime(2024, 1, 1),
      );

      final mockBrand = Brand(
        id: 'brand1',
        nombre: 'Nike',
        slug: 'nike',
        activo: true,
        createdAt: DateTime(2024, 1, 1),
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
        activo: true,
        createdAt: DateTime(2024, 1, 1),
      );

      final mockPagedResponse = PagedProducts(
        count: 1,
        results: [mockProduct],
        next: null,
        previous: null,
      );

      when(
        () => mockRepository.listProducts(search: 'Test'),
      ).thenAnswer((_) async => Right(mockPagedResponse));

      // Act
      final result = await mockRepository.listProducts(search: 'Test');

      // Assert
      expect(result, isA<Right<Failure, PagedProducts>>());
      verify(() => mockRepository.listProducts(search: 'Test')).called(1);
    });

    test('debe aplicar filtros de precio', () async {
      // Arrange
      final mockCategory = Category(
        id: 'cat1',
        nombre: 'Ropa',
        slug: 'ropa',
        activo: true,
        createdAt: DateTime(2024, 1, 1),
      );

      final mockBrand = Brand(
        id: 'brand1',
        nombre: 'Nike',
        slug: 'nike',
        activo: true,
        createdAt: DateTime(2024, 1, 1),
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
        activo: true,
        createdAt: DateTime(2024, 1, 1),
      );

      final mockPagedResponse = PagedProducts(
        count: 1,
        results: [mockProduct],
        next: null,
        previous: null,
      );

      when(
        () => mockRepository.listProducts(minPrice: 50.0, maxPrice: 150.0),
      ).thenAnswer((_) async => Right(mockPagedResponse));

      // Act
      final result = await mockRepository.listProducts(
        minPrice: 50.0,
        maxPrice: 150.0,
      );

      // Assert
      expect(result, isA<Right<Failure, PagedProducts>>());
      result.fold((failure) => fail('No debería retornar failure'), (
        pagedProducts,
      ) {
        final producto = pagedProducts.results.first;
        expect(producto.precio.cantidad, greaterThanOrEqualTo(50.0));
        expect(producto.precio.cantidad, lessThanOrEqualTo(150.0));
      });
      verify(
        () => mockRepository.listProducts(minPrice: 50.0, maxPrice: 150.0),
      ).called(1);
    });

    test('debe manejar paginación correctamente', () async {
      // Arrange
      final mockCategory = Category(
        id: 'cat1',
        nombre: 'Ropa',
        slug: 'ropa',
        activo: true,
        createdAt: DateTime(2024, 1, 1),
      );

      final mockBrand = Brand(
        id: 'brand1',
        nombre: 'Nike',
        slug: 'nike',
        activo: true,
        createdAt: DateTime(2024, 1, 1),
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
        activo: true,
        createdAt: DateTime(2024, 1, 1),
      );

      final secondPageResponse = PagedProducts(
        count: 25,
        results: [mockProduct],
        next: 'http://api.com?page=3',
        previous: 'http://api.com?page=1',
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
  });
}
