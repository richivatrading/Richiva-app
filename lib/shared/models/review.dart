class Review {
  final String id;
  final String productId;
  final String userName;
  final double rating;
  final String? title;
  final String comment;
  final DateTime createdAt;
  final bool verifiedPurchase;
  final String? size;
  final String? color;

  const Review({
    required this.id,
    required this.productId,
    required this.userName,
    required this.rating,
    this.title,
    required this.comment,
    required this.createdAt,
    this.verifiedPurchase = true,
    this.size,
    this.color,
  });

  Review copyWith({
    String? id,
    String? productId,
    String? userName,
    double? rating,
    String? title,
    String? comment,
    DateTime? createdAt,
    bool? verifiedPurchase,
    String? size,
    String? color,
  }) => Review(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        userName: userName ?? this.userName,
        rating: rating ?? this.rating,
        title: title ?? this.title,
        comment: comment ?? this.comment,
        createdAt: createdAt ?? this.createdAt,
        verifiedPurchase: verifiedPurchase ?? this.verifiedPurchase,
        size: size ?? this.size,
        color: color ?? this.color,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'userName': userName,
        'rating': rating,
        'title': title,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
        'verifiedPurchase': verifiedPurchase,
        'size': size,
        'color': color,
      };

  static Review fromJson(Map<String, dynamic> j) => Review(
        id: j['id'] as String,
        productId: j['productId'] as String,
        userName: j['userName'] as String,
        rating: (j['rating'] as num).toDouble(),
        title: j['title'] as String?,
        comment: j['comment'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        verifiedPurchase: j['verifiedPurchase'] as bool? ?? true,
        size: j['size'] as String?,
        color: j['color'] as String?,
      );
}

class RatingSummary {
  final double average;
  final int count;
  final Map<int, int> distribution; // 1..5 → count

  const RatingSummary({
    required this.average,
    required this.count,
    required this.distribution,
  });

  static const empty = RatingSummary(
    average: 0,
    count: 0,
    distribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
  );

  factory RatingSummary.fromList(List<Review> reviews) {
    if (reviews.isEmpty) return empty;
    final dist = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    var sum = 0.0;
    for (final r in reviews) {
      sum += r.rating;
      final star = r.rating.round().clamp(1, 5);
      dist[star] = (dist[star] ?? 0) + 1;
    }
    return RatingSummary(
      average: sum / reviews.length,
      count: reviews.length,
      distribution: dist,
    );
  }
}