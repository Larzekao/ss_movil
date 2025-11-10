import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/features/accounts/presentation/pages/splash_page.dart';
import 'package:ss_movil/features/accounts/presentation/pages/login_page.dart';
import 'package:ss_movil/features/accounts/presentation/pages/register_page.dart';
import 'package:ss_movil/features/accounts/presentation/pages/home_page.dart';
import 'package:ss_movil/features/accounts/presentation/pages/admin_page.dart';
import 'package:ss_movil/features/accounts/presentation/pages/users/users_list_page.dart';
import 'package:ss_movil/features/accounts/presentation/pages/users/user_form_page.dart';
import 'package:ss_movil/features/accounts/presentation/pages/users/user_detail_page.dart';
import 'package:ss_movil/features/accounts/presentation/pages/roles/roles_list_page.dart';
import 'package:ss_movil/features/accounts/presentation/pages/roles/role_form_page.dart';
import 'package:ss_movil/features/accounts/presentation/pages/permissions/permissions_list_page.dart';
import 'package:ss_movil/features/products/presentation/pages/products/products_list_page.dart';
import 'package:ss_movil/features/products/presentation/pages/products/product_detail_page.dart';
import 'package:ss_movil/features/products/presentation/pages/products/product_form_page.dart';
import 'package:ss_movil/features/products/presentation/pages/categories/categories_list_page.dart';
import 'package:ss_movil/features/products/presentation/pages/categories/category_form_page.dart';
import 'package:ss_movil/features/products/presentation/pages/brands/brands_list_page.dart';
import 'package:ss_movil/features/products/presentation/pages/brands/brand_form_page.dart';
import 'package:ss_movil/shared/widgets/protected_route.dart';

/// Configuración de rutas con go_router
final goRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),

    // Ruta protegida: Panel de administración
    GoRoute(
      path: '/admin',
      builder: (context, state) => const ProtectedRoute(
        requiredPermission: 'admin.acceso',
        child: AdminPage(),
      ),
    ),

    // === RUTAS DE USUARIOS ===
    GoRoute(
      path: '/accounts/users',
      builder: (context, state) => const UsersListPage(),
    ),
    GoRoute(
      path: '/accounts/users/new',
      builder: (context, state) => const UserFormPage(),
    ),
    GoRoute(
      path: '/accounts/users/:id',
      builder: (context, state) {
        final userId = state.pathParameters['id']!;
        return UserDetailPage(userId: userId);
      },
    ),
    GoRoute(
      path: '/accounts/users/:id/edit',
      builder: (context, state) {
        final userId = state.pathParameters['id']!;
        return UserFormPage(userId: userId);
      },
    ),

    // === RUTAS DE ROLES ===
    GoRoute(
      path: '/accounts/roles',
      builder: (context, state) => const RolesListPage(),
    ),
    GoRoute(
      path: '/accounts/roles/new',
      builder: (context, state) => const RoleFormPage(isEdit: false),
    ),
    GoRoute(
      path: '/accounts/roles/:id',
      builder: (context, state) {
        final roleId = state.pathParameters['id']!;
        return RoleFormPage(roleId: roleId, isEdit: false);
      },
    ),
    GoRoute(
      path: '/accounts/roles/:id/edit',
      builder: (context, state) {
        final roleId = state.pathParameters['id']!;
        return RoleFormPage(roleId: roleId, isEdit: true);
      },
    ),

    // === RUTAS DE PERMISOS ===
    GoRoute(
      path: '/accounts/permissions',
      builder: (context, state) => const PermissionsListPage(),
    ),

    // === RUTAS DE PRODUCTOS ===
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductsListPage(),
    ),
    GoRoute(
      path: '/products/new',
      builder: (context, state) => const ProductFormPage(),
    ),
    GoRoute(
      path: '/products/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        return ProductDetailPage(slug: slug);
      },
    ),
    GoRoute(
      path: '/products/:slug/edit',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        return ProductFormPage(slug: slug);
      },
    ),

    // === RUTAS DE CATEGORÍAS ===
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesListPage(),
    ),
    GoRoute(
      path: '/categories/new',
      builder: (context, state) => const CategoryFormPage(),
    ),
    GoRoute(
      path: '/categories/:id/edit',
      builder: (context, state) {
        final categoryId = state.pathParameters['id']!;
        return CategoryFormPage(categoryId: categoryId);
      },
    ),

    // === RUTAS DE MARCAS ===
    GoRoute(
      path: '/brands',
      builder: (context, state) => const BrandsListPage(),
    ),
    GoRoute(
      path: '/brands/new',
      builder: (context, state) => const BrandFormPage(),
    ),
    GoRoute(
      path: '/brands/:id/edit',
      builder: (context, state) {
        final brandId = state.pathParameters['id']!;
        return BrandFormPage(brandId: brandId);
      },
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Ruta no encontrada: ${state.uri}'))),
);
