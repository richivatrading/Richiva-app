import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review.dart';
import '../models/order.dart';
import '../persistence/persisted_notifier.dart';
import 'orders_provider.dart';

class ReviewsNotifier extends PersistedNotifier<Map<String, List<Review>>> {
  ReviewsNotifier()
      : super(
          storageKey: 'richiva.reviews.v1',
          seed: _seed(),
        );

  static Map<String, List<Review>> _seed() {
    final now = DateTime.now();
    return {
      'f1': [
        Review(
          id: 'rev-1',
          productId: 'f1',
          userName: 'Priya K.',
          rating: 5.0,
          title: 'Luxuriously soft',
          comment:
              'Best cashmere I\'ve owned. The color is exactly as shown, and it\'s held up beautifully after three washes.',
          createdAt: now.subtract(const Duration(days: 5)),
          size: 'M',
          color: 'Beige',
        ),
        Review(
          id: 'rev-2',
          productId: 'f1',
          userName: 'Anjali R.',
          rating: 4.0,
          title: 'Good, slightly large',
          comment:
              'Fits a bit loose for the size chart. I\'d size down next time. Quality is great though.',
          createdAt: now.subtract(const Duration(days: 12)),
          size: 'L',
          color: 'Beige',
        ),
        Review(
          id: 'rev-3',
          productId: 'f1',
          userName: 'Rohan M.',
          rating: 5.0,
          comment:
              'Bought this for my wife. She loves it. Warm, soft, and the drape is lovely.',
          createdAt: now.subtract(const Duration(days: 22)),
          size: 'S',
          color: 'Beige',
        ),
      ],
      'n2': [
        Review(
          id: 'rev-4',
          productId: 'n2',
          userName: 'Sneha P.',
          rating: 5.0,
          title: 'Everyday staple',
          comment:
              'I\'ve worn this top 20 times and it still looks new. Pairs with everything.',
          createdAt: now.subtract(const Duration(days: 3)),
          size: 'S',
          color: 'White',
        ),
        Review(
          id: 'rev-5',
          productId: 'n2',
          userName: 'Maya T.',
          rating: 4.0,
          comment:
              'Ribbing is substantial. Slightly cropped on my frame but that\'s the style.',
          createdAt: now.subtract(const Duration(days: 8)),
          size: 'M',
          color: 'White',
        ),
      ],
      'f3': [
        Review(
          id: 'rev-6',
          productId: 'f3',
          userName: 'Aakash S.',
          rating: 5.0,
          title: 'Perfect fit',
          comment: 'True to size. The denim quality is excellent for the price.',
          createdAt: now.subtract(const Duration(days: 15)),
          size: 'M',
          color: 'Blue',
        ),
      ],
      't1': [
        Review(
          id: 'rev-7',
          productId: 't1',
          userName: 'Nisha B.',
          rating: 4.0,
          comment: 'Cute and warm. Sizing runs small — size up.',
          createdAt: now.subtract(const Duration(days: 6)),
          size: 'L',
        ),
      ],
    };
  }

  @override
  dynamic serialize(Map<String, List<Review>> state) => state.map(
        (productId, reviews) => MapEntry(
          productId,
          reviews.map((r) => r.toJson()).toList(),
        ),
      );

  @override
  Map<String, List<Review>> deserialize(dynamic json) {
    final map = json as Map<String, dynamic>;
    return map.map(
      (productId, reviews) => MapEntry(
        productId,
        (reviews as List<dynamic>)
            .map((e) => Review.fromJson(e as Map<String, dynamic>))
            .toList()
            .cast<Review>(),
      ),
    );
  }

  void addReview({
    required String productId,
    required String userName,
    required double rating,
    String? title,
    required String comment,
    String? size,
    String? color,
  }) {
    final review = Review(
      id: 'rev-${DateTime.now().microsecondsSinceEpoch}',
      productId: productId,
      userName: userName,
      rating: rating,
      title: title,
      comment: comment,
      createdAt: DateTime.now(),
      verifiedPurchase: true,
      size: size,
      color: color,
    );
    final list = <Review>[...(state[productId] ?? const []), review];
    state = {...state, productId: list};
  }
}

final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, Map<String, List<Review>>>(
  (_) => ReviewsNotifier(),
);

final reviewsForProductProvider =
    Provider.family<List<Review>, String>((ref, productId) {
  return ref.watch(reviewsProvider)[productId] ?? const [];
});

final productRatingSummaryProvider =
    Provider.family<RatingSummary, String>((ref, productId) {
  return RatingSummary.fromList(ref.watch(reviewsForProductProvider(productId)));
});

/// True if the user has a delivered order containing this product.
final hasPurchasedProvider =
    Provider.family<bool, String>((ref, productId) {
  final orders = ref.watch(ordersProvider);
  return orders.any((o) =>
      o.status.isDelivered &&
      o.items.any((i) => i.productId == productId));
});