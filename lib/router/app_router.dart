import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/verify_screen.dart';
import '../shared/widgets/scaffold_with_nav_bar.dart';
import '../features/try_on/try_on_screen.dart';
import '../features/home/home_screen.dart';
import '../features/product/product_screen.dart';
import '../features/bag/bag_screen.dart';
import '../features/checkout/address_screen.dart';
import '../features/checkout/shipping_screen.dart';
import '../features/checkout/payment_screen.dart';
import '../features/checkout/review_screen.dart';
import '../features/checkout/order_result_screen.dart';
import '../features/account/account_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/orders/order_detail_screen.dart';
import '../features/orders/track_order_screen.dart';
import '../features/orders/cancel_order_screen.dart';
import '../features/orders/return_screen.dart';
import '../features/orders/returns_screen.dart';
import '../features/vouchers/vouchers_screen.dart';
import '../features/loyalty/loyalty_screen.dart';
import '../features/wishlist/wishlist_screen.dart';
import '../features/search/search_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/categories/shop_screen.dart';
import '../features/collections/collection_screen.dart';
import '../features/reviews/reviews_screen.dart';
import '../features/size_guide/size_guide_screen.dart';
import '../features/custom_garment/custom_garment_screen.dart';
import '../features/support/support_screen.dart';
import '../features/support/chat_screen.dart';
import '../features/support/ai_screen.dart';
import '../features/referrals/referrals_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/notifications/notification_settings_screen.dart';
import '../features/states_gallery/states_gallery_screen.dart';
import '../shared/screens/not_found_screen.dart';
import '../shared/providers/bag_provider.dart';
import '../shared/providers/checkout_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // ── NEW: checkout requires non-empty bag ──────────────────────────
      if (loc.startsWith('/checkout')) {
        final bag = ref.read(bagProvider);
        if (bag.isEmpty) return '/bag';
      }
      // ──────────────────────────────────────────────────────────────────

      return null;
    },
    routes: [
      ShellRoute(
        builder: (_, __, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const HomeScreen(),
            redirect: (context, state) async {
              final prefs = await SharedPreferences.getInstance();
              final done = prefs.getBool('onboarding_done') ?? false;
              if (!done) return '/onboarding';
              return null;
            },
          ),
          GoRoute(
            path: '/categories',
            builder: (_, __) => const CategoriesScreen(),
          ),
          GoRoute(
            path: '/bag',
            builder: (_, __) => const BagScreen(),
          ),
          GoRoute(
            path: '/account',
            builder: (_, __) => const AccountScreen(),
          ),
        ],
      ),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/verify',
        builder: (_, __) => const VerifyScreen(),
      ),
      GoRoute(path: '/product/:id', builder: (_, s) => ProductScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/product/:id/reviews', builder: (_, s) => ReviewsScreen(id: s.pathParameters['id']!)),
      GoRoute(
        path: '/try-on',
        builder: (_, s) => TryOnScreen(
          initialProductName: s.uri.queryParameters['productName'],
        ),
      ),
      GoRoute(
        path: '/checkout/address',
        builder: (_, __) => const AddressScreen(),
        redirect: (context, state) {
          final bag = ref.read(bagProvider);
          if (bag.isEmpty) return '/bag';
          return null;
        },
      ),
      GoRoute(
        path: '/checkout/shipping',
        builder: (_, __) => const ShippingScreen(),
        redirect: (context, state) {
          final bag = ref.read(bagProvider);
          if (bag.isEmpty) return '/bag';
          final checkout = ref.read(checkoutProvider);
          if (checkout.addressId == null) return '/checkout/address';
          return null;
        },
      ),
      GoRoute(
        path: '/checkout/payment',
        builder: (_, __) => const PaymentScreen(),
        redirect: (context, state) {
          final bag = ref.read(bagProvider);
          if (bag.isEmpty) return '/bag';
          final checkout = ref.read(checkoutProvider);
          if (checkout.shippingId == null) return '/checkout/shipping';
          return null;
        },
      ),
      GoRoute(
        path: '/checkout/review',
        builder: (_, __) => const ReviewScreen(),
        redirect: (context, state) {
          final bag = ref.read(bagProvider);
          if (bag.isEmpty) return '/bag';
          final checkout = ref.read(checkoutProvider);
          if (checkout.paymentId == null) return '/checkout/payment';
          return null;
        },
      ),
      GoRoute(path: '/order/:id/result', builder: (_, s) => OrderResultScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
      GoRoute(path: '/orders/:id', builder: (_, s) => OrderDetailScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/orders/:id/track', builder: (_, s) => TrackOrderScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/orders/:id/cancel', builder: (_, s) => CancelOrderScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/orders/:id/return', builder: (_, s) => ReturnScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/returns', builder: (_, __) => const ReturnsScreen()),
      GoRoute(path: '/vouchers', builder: (_, __) => const VouchersScreen()),
      GoRoute(path: '/loyalty', builder: (_, __) => const LoyaltyScreen()),
      GoRoute(path: '/wishlist', builder: (_, __) => const WishlistScreen()),
      GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
      GoRoute(path: '/shop/:slug', builder: (_, s) => ShopScreen(slug: s.pathParameters['slug']!)),
      GoRoute(path: '/collections/:id', builder: (_, s) => CollectionScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/size-guide', builder: (_, __) => const SizeGuideScreen()),
      GoRoute(path: '/custom', builder: (_, __) => const CustomGarmentScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/notifications/settings', builder: (_, __) => const NotificationSettingsScreen()),
      GoRoute(path: '/support', builder: (_, __) => const SupportScreen()),
      GoRoute(path: '/support/chat', builder: (_, __) => const ChatScreen()),
      GoRoute(path: '/support/ai', builder: (_, __) => const AiScreen()),
      GoRoute(path: '/referrals', builder: (_, __) => const ReferralsScreen()),
      GoRoute(path: '/states', builder: (_, __) => const StatesGalleryScreen()),
    ],
    errorBuilder: (_, __) => const NotFoundScreen(),
  );
});