import 'package:dio/dio.dart';
import '../models/notification.dart';
import '../providers/bag_provider.dart' show BagItem;
import '../models/product.dart';
import '../models/order.dart';
import '../models/review.dart';

class ApiClient {
  final Dio _dio;

  // Local mock database for features not covered by jsonplaceholder
  static final List<Order> _mockOrders = [];
  static final List<Review> _mockReviews = [];
  static final Set<String> _mockWishlist = {};
  static final Map<String, dynamic> _mockLoyalty = {
    'points': 1250,
    'tier': 'Gold',
    'vouchers': [
      {'code': 'LOYAL10', 'type': 'percentage', 'value': 10, 'minOrder': 2000},
      {'code': 'LOYAL20', 'type': 'fixed', 'value': 500, 'minOrder': 5000},
    ],
  };
  static final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: '1',
      title: 'Welcome to Richiva!',
      body: 'Enjoy 10% off your first order.',
      type: NotificationType.promo,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationModel(
      id: '2',
      title: 'Order Shipped',
      body: 'Your order #ORD-1234 is on the way.',
      type: NotificationType.order,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://jsonplaceholder.typicode.com',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

  // ── 1. PRODUCTS ────────────────────────────────────────────────────────
  Future<List<Product>> getProducts({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final response = await _dio.get('/posts');
    return (response.data as List).take(20).map((json) => Product(
      id: json['id'].toString(),
      name: 'Dynamic ${json['title'].toString().substring(0, 1).toUpperCase()}${json['title'].toString().substring(1, 15)}...',
      brand: 'Richiva',
      imageUrl: 'https://picsum.photos/seed/${json['id']}/600/800',
      price: (2500 + (json['id'] * 50)).toDouble(),
      comparePrice: (3500 + (json['id'] * 50)).toDouble(),
      description: json['body'],
      images: [
        'https://picsum.photos/seed/${json['id']}-a/600/800',
        'https://picsum.photos/seed/${json['id']}-b/600/800',
        'https://picsum.photos/seed/${json['id']}-c/600/800',
      ],
      sizes: const ['S', 'M', 'L', 'XL'],
      colors: const ['Black', 'White', 'Navy'],
      badge: json['id'] <= 3 ? 'New' : null,
    )).toList();
  }

  Future<Product> getProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final response = await _dio.get('/posts/$id');
    final json = response.data as Map<String, dynamic>;
    return Product(
      id: id,
      name: 'Dynamic ${json['title'].toString().substring(0, 1).toUpperCase()}${json['title'].toString().substring(1, 20)}...',
      brand: 'Richiva',
      imageUrl: 'https://picsum.photos/seed/$id/600/800',
      price: 3500 + (int.parse(id) * 50),
      comparePrice: 5000,
      description: json['body'],
      images: [
        'https://picsum.photos/seed/$id-a/600/800',
        'https://picsum.photos/seed/$id-b/600/800',
        'https://picsum.photos/seed/$id-c/600/800',
      ],
      sizes: const ['S', 'M', 'L', 'XL'],
      colors: const ['Black', 'White', 'Navy', 'Beige'],
    );
  }

  // ── 2. AUTH ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password required');
    }
    return {
      'token': 'fake-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Dynamic User',
        'email': email,
        'avatar': 'https://picsum.photos/seed/user/200/200',
      },
    };
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'token': 'fake-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'email': email,
      },
    };
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ── 3. CART / BAG ──────────────────────────────────────────────────────
  Future<List<BagItem>> getCart() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return []; // In real app, fetch from server
  }

  Future<void> syncCart(List<BagItem> items) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulate server sync
  }

  Future<void> clearCart() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // ── 4. ORDERS ──────────────────────────────────────────────────────────
  Future<List<Order>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_mockOrders)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<Order> placeOrder(Order order) async {
    await Future.delayed(const Duration(seconds: 1));
    final newOrder = order.copyWith(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      status: OrderStatus.toShip,
      createdAt: DateTime.now(),
    );
    _mockOrders.insert(0, newOrder);
    return newOrder;
  }

  Future<Order> cancelOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _mockOrders[index] = _mockOrders[index].copyWith(status: OrderStatus.cancelled);
      return _mockOrders[index];
    }
    throw Exception('Order not found');
  }

  Future<Order> requestReturn(String orderId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _mockOrders[index] = _mockOrders[index].copyWith(status: OrderStatus.returned);
      return _mockOrders[index];
    }
    throw Exception('Order not found');
  }

  // ── 5. WISHLIST ────────────────────────────────────────────────────────
  Future<Set<String>> getWishlist() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Set.from(_mockWishlist);
  }

  Future<void> toggleWishlist(String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_mockWishlist.contains(productId)) {
      _mockWishlist.remove(productId);
    } else {
      _mockWishlist.add(productId);
    }
  }

  // ── 6. LOYALTY ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getLoyalty() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Map.from(_mockLoyalty);
  }

  Future<void> redeemVoucher(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final vouchers = List<Map<String, dynamic>>.from(_mockLoyalty['vouchers'] as List);
    final index = vouchers.indexWhere((v) => v['code'] == code);
    if (index != -1) {
      vouchers.removeAt(index);
      _mockLoyalty['vouchers'] = vouchers;
    }
  }

  Future<void> addPoints(int points) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockLoyalty['points'] = (_mockLoyalty['points'] as int) + points;
    // Tier upgrade logic
    final pts = _mockLoyalty['points'] as int;
    if (pts >= 5000) _mockLoyalty['tier'] = 'Platinum';
    else if (pts >= 2000) _mockLoyalty['tier'] = 'Gold';
    else if (pts >= 500) _mockLoyalty['tier'] = 'Silver';
    else _mockLoyalty['tier'] = 'Bronze';
  }

  // ── 7. REVIEWS ─────────────────────────────────────────────────────────
  Future<List<Review>> getReviews(String productId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockReviews.where((r) => r.productId == productId).toList();
  }

  Future<Review> submitReview(Review review) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newReview = review.copyWith(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    _mockReviews.add(newReview);
    return newReview;
  }

  // ── 8. NOTIFICATIONS ───────────────────────────────────────────────────
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_mockNotifications)..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> markNotificationRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _mockNotifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _mockNotifications[index] = _mockNotifications[index].copyWith(isRead: true);
    }
  }

  Future<void> markAllNotificationsRead() async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i < _mockNotifications.length; i++) {
      _mockNotifications[i] = _mockNotifications[i].copyWith(isRead: true);
    }
  }
}