class Product {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final double price;
  final double? comparePrice;
  final String? badge;

  // ── Optional detail fields (default to safe values so cards still work) ──
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final String? description;
  final double rating;
  final int reviewCount;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.price,
    this.comparePrice,
    this.badge,
    this.images = const [],
    this.sizes = const ['S', 'M', 'L', 'XL'],
    this.colors = const ['Black', 'Beige', 'White'],
    this.description,
    this.rating = 4.5,
    this.reviewCount = 0,
  });

  bool get isOnSale => comparePrice != null && comparePrice! > price;

  int? get discountPercent => isOnSale
      ? (((comparePrice! - price) / comparePrice!) * 100).round()
      : null;

  /// Always non-empty — falls back to the card image.
  List<String> get galleryImages => images.isEmpty ? [imageUrl] : images;
}