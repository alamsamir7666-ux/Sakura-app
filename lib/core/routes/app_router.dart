import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/products/products_screen.dart';
import '../../features/products/product_detail_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/orders/order_detail_screen.dart';
import '../../features/orders/track_order_screen.dart';
import '../../features/wishlist/wishlist_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/addresses_screen.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/auth/sign_up_screen.dart';
import '../../features/admin/admin_screen.dart';
import '../../features/blog/blog_screen.dart';
import '../../features/blog/blog_article_screen.dart';
import '../../features/compare/compare_screen.dart';
import '../../features/giftcards/gift_cards_screen.dart';
import '../../features/loyalty/loyalty_screen.dart';
import '../../features/referral/referral_screen.dart';
import '../../features/subscriptions/subscriptions_screen.dart';
import '../../features/preorder/pre_order_screen.dart';
import '../../features/preorder/pre_order_checkout_screen.dart';
import '../../features/preorder/pre_order_detail_screen.dart';
import '../../features/email_prefs/email_preferences_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/not_found/not_found_screen.dart';
import '../../features/skin_profile/skin_profile_screen.dart';
import '../../features/returns/returns_screen.dart';
import '../../features/newsletter/newsletter_screen.dart';
import '../../shared/widgets/app_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Main shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/products',
            name: 'products',
            builder: (context, state) => const ProductsScreen(),
          ),
          GoRoute(
            path: '/cart',
            name: 'cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: '/orders',
            name: 'orders',
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: '/wishlist',
            name: 'wishlist',
            builder: (context, state) => const WishlistScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // Full-screen routes (no bottom nav)
      GoRoute(
        path: '/products/:id',
        name: 'productDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        name: 'orderDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return OrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/track',
        name: 'trackOrder',
        builder: (context, state) => const TrackOrderScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        name: 'signIn',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        name: 'signUp',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: '/blog',
        name: 'blog',
        builder: (context, state) => const BlogScreen(),
      ),
      GoRoute(
        path: '/blog/:id',
        name: 'blogArticle',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return BlogArticleScreen(postId: id);
        },
      ),
      GoRoute(
        path: '/compare',
        name: 'compare',
        builder: (context, state) => const CompareScreen(),
      ),
      GoRoute(
        path: '/gift-cards',
        name: 'giftCards',
        builder: (context, state) => const GiftCardsScreen(),
      ),
      GoRoute(
        path: '/loyalty',
        name: 'loyalty',
        builder: (context, state) => const LoyaltyScreen(),
      ),
      GoRoute(
        path: '/referral',
        name: 'referral',
        builder: (context, state) => const ReferralScreen(),
      ),
      GoRoute(
        path: '/subscriptions',
        name: 'subscriptions',
        builder: (context, state) => const SubscriptionsScreen(),
      ),
      GoRoute(
        path: '/pre-order',
        name: 'preOrder',
        builder: (context, state) => const PreOrderScreen(),
      ),
      GoRoute(
        path: '/email-preferences',
        name: 'emailPreferences',
        builder: (context, state) => const EmailPreferencesScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/addresses',
        name: 'addresses',
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/pre-order/checkout',
        name: 'preOrderCheckout',
        builder: (context, state) => const PreOrderCheckoutScreen(),
      ),
      GoRoute(
        path: '/pre-order/:id',
        name: 'preOrderDetail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PreOrderDetailScreen(preOrderId: id);
        },
      ),
      GoRoute(
        path: '/skin-profile',
        name: 'skinProfile',
        builder: (context, state) => const SkinProfileScreen(),
      ),
      GoRoute(
        path: '/returns',
        name: 'returns',
        builder: (context, state) => const ReturnsScreen(),
      ),
      GoRoute(
        path: '/newsletter',
        name: 'newsletter',
        builder: (context, state) => const NewsletterScreen(),
      ),
    ],
    // 404 wildcard
    redirect: (context, state) {
      final knownPaths = [
        '/', '/products', '/cart', '/orders', '/wishlist', '/profile',
        '/checkout', '/track', '/sign-in', '/sign-up', '/admin',
        '/blog', '/compare', '/gift-cards', '/loyalty', '/referral',
        '/subscriptions', '/pre-order', '/email-preferences',
        '/search', '/settings', '/addresses', '/skin-profile',
        '/returns', '/newsletter',
      ];
      final isKnown = knownPaths.any((p) => state.uri.path == p) ||
          state.uri.path.startsWith('/products/') ||
          state.uri.path.startsWith('/orders/') ||
          state.uri.path.startsWith('/blog/') ||
          state.uri.path.startsWith('/pre-order/');
      if (!isKnown && state.uri.path != '/not-found') {
        return '/not-found';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/not-found',
        name: 'notFound',
        builder: (context, state) => const NotFoundScreen(),
      ),
    ],
  );
});
