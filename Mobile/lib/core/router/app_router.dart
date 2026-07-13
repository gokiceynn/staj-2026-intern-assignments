import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_orders_screen.dart';
import '../../features/admin/presentation/screens/admin_product_form_screen.dart';
import '../../features/admin/presentation/screens/admin_products_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/catalog/domain/entities/product.dart';
import '../../features/catalog/domain/entities/product_query.dart';
import '../../features/catalog/presentation/screens/categories_screen.dart';
import '../../features/catalog/presentation/screens/home_screen.dart';
import '../../features/catalog/presentation/screens/product_detail_screen.dart';
import '../../features/catalog/presentation/screens/product_list_screen.dart';
import '../../features/catalog/presentation/screens/search_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/orders/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/order_success_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/profile/domain/entities/address.dart';
import '../../features/profile/presentation/screens/account_screen.dart';
import '../../features/profile/presentation/screens/address_form_screen.dart';
import '../../features/profile/presentation/screens/addresses_screen.dart';
import '../../features/shell/main_shell.dart';

/// Giriş gerektiren yol önekleri.
const _protectedPrefixes = ['/checkout', '/orders', '/addresses', '/admin'];

final routerProvider = Provider<GoRouter>((ref) {
  // Auth durumu değişince redirect'lerin yeniden değerlendirilmesi için.
  final refreshNotifier = ValueNotifier(0);
  ref
    ..listen(authControllerProvider, (_, _) => refreshNotifier.value++)
    ..onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final isLoggedIn = auth.value != null;
      final isAdmin = auth.value?.isAdmin ?? false;
      final authResolved = !auth.isLoading;
      final location = state.matchedLocation;

      final needsAuth =
          _protectedPrefixes.any((prefix) => location.startsWith(prefix));

      if (needsAuth && authResolved && !isLoggedIn) {
        return Uri(
          path: '/login',
          queryParameters: {'redirect': state.uri.toString()},
        ).toString();
      }
      if (location.startsWith('/admin') && authResolved && !isAdmin) {
        return '/home';
      }
      // Girişliyken login/register'a gitmeye çalışma → hedefe yönlendir.
      if ((location == '/login' || location == '/register') && isLoggedIn) {
        return state.uri.queryParameters['redirect'] ?? '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: '/login',
        builder: (_, state) =>
            LoginScreen(redirect: state.uri.queryParameters['redirect']),
      ),
      GoRoute(
        path: '/register',
        builder: (_, state) =>
            RegisterScreen(redirect: state.uri.queryParameters['redirect']),
      ),
      // Alt menülü ana kabuk — sekme durumları korunur.
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                builder: (_, _) => const CategoriesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (_, _) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (_, _) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),
      // Kabuk dışı (tam ekran) sayfalar.
      GoRoute(
        path: '/product/:id',
        builder: (_, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/products',
        builder: (_, state) {
          final params = state.uri.queryParameters;
          final isFlash = params['flash'] == '1';
          return ProductListScreen(
            title: params['title'],
            initialQuery: ProductQuery(
              q: params['q'],
              categoryId: params['category'],
              flashDealsOnly: isFlash,
              sort: isFlash ? ProductSort.discount : ProductSort.featured,
            ),
          );
        },
      ),
      GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
      GoRoute(path: '/checkout', builder: (_, _) => const CheckoutScreen()),
      GoRoute(
        path: '/order-success/:id',
        builder: (_, state) =>
            OrderSuccessScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/orders',
        builder: (_, _) => const OrdersScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) =>
                OrderDetailScreen(orderId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/addresses',
        builder: (_, _) => const AddressesScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (_, _) => const AddressFormScreen(),
          ),
          GoRoute(
            path: 'edit',
            builder: (_, state) =>
                AddressFormScreen(existing: state.extra as Address?),
          ),
        ],
      ),
      GoRoute(
        path: '/admin',
        builder: (_, _) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'products',
            builder: (_, _) => const AdminProductsScreen(),
          ),
          GoRoute(
            path: 'product-form',
            builder: (_, state) =>
                AdminProductFormScreen(existing: state.extra as Product?),
          ),
          GoRoute(
            path: 'orders',
            builder: (_, _) => const AdminOrdersScreen(),
          ),
        ],
      ),
    ],
  );
});
