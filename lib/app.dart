import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/features/accounts/presentation/pages/home_page.dart' as accounts_home;
import 'package:ss_movil/features/auth/presentation/pages/home_page.dart';
import 'package:ss_movil/features/auth/presentation/pages/login_page_simple.dart';
import 'package:ss_movil/features/customers/presentation/pages/addresses_page.dart';
import 'package:ss_movil/features/customers/presentation/pages/favorites_page.dart';
import 'package:ss_movil/features/customers/presentation/pages/preferences_page.dart';
import 'package:ss_movil/features/customers/presentation/pages/profile_page.dart';
import 'package:ss_movil/features/customers/presentation/pages/product_detail_page_example.dart';

/// Router principal de la aplicación
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      // Permitir acceso sin validación de autenticación
      // Solo para desarrollo y testing de UI
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: [
          // Rutas protegidas
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfilePage(),
            pageBuilder: (context, state) =>
                MaterialPage(key: state.pageKey, child: const ProfilePage()),
          ),
          GoRoute(
            path: 'addresses',
            builder: (context, state) => const AddressesPage(),
            pageBuilder: (context, state) =>
                MaterialPage(key: state.pageKey, child: const AddressesPage()),
          ),
          GoRoute(
            path: 'preferences',
            builder: (context, state) => const PreferencesPage(),
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const PreferencesPage(),
            ),
          ),
          GoRoute(
            path: 'favorites',
            builder: (context, state) => const FavoritesPage(),
            pageBuilder: (context, state) =>
                MaterialPage(key: state.pageKey, child: const FavoritesPage()),
          ),
          GoRoute(
            path: 'product/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id'] ?? '0');
              return ProductDetailPageExample(
                productId: id,
                productName: 'Producto #$id',
                productDescription: 'Descripción del producto #$id',
                productPrice: 99.99 + (id * 10),
              );
            },
            pageBuilder: (context, state) {
              final id = int.parse(state.pathParameters['id'] ?? '0');
              return MaterialPage(
                key: state.pageKey,
                child: ProductDetailPageExample(
                  productId: id,
                  productName: 'Producto #$id',
                  productDescription: 'Descripción del producto #$id',
                  productPrice: 99.99 + (id * 10),
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const accounts_home.HomePage(),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Página no encontrada',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Ruta: ${state.uri.path}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Volver al Inicio'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});

/// Widget principal de la aplicación
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SmartSales',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      routerConfig: router,
    );
  }
}
