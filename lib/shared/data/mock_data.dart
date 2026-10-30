import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';

final List<Category> mockCategories = [
  const Category(id: 'women',   name: 'Women',   icon: Icons.woman,         tint: Color(0xFFFCE7F3)),
  const Category(id: 'men',     name: 'Men',     icon: Icons.man,           tint: Color(0xFFDBEAFE)),
  const Category(id: 'kids',    name: 'Kids',    icon: Icons.child_care,    tint: Color(0xFFFEF3C7)),
  const Category(id: 'shoes',   name: 'Shoes',   icon: Icons.directions_walk, tint: Color(0xFFDCFCE7)),
  const Category(id: 'bags',    name: 'Bags',    icon: Icons.shopping_bag,  tint: Color(0xFFF3E8FF)),
  const Category(id: 'beauty',  name: 'Beauty',  icon: Icons.spa,           tint: Color(0xFFFFE4E6)),
  const Category(id: 'jewelry', name: 'Jewelry', icon: Icons.diamond,       tint: Color(0xFFE0F2FE)),
  const Category(id: 'sale',    name: 'Sale',    icon: Icons.local_fire_department, tint: Color(0xFFFEE2E2)),
];

final List<Product> mockFlashSale = [
  const Product(id: 'f1', name: 'Cashmere Sweater', brand: 'Richiva', imageUrl: 'https://picsum.photos/seed/f1/600/800',
    price: 3499, comparePrice: 6999, badge: '-50%'),
  const Product(id: 'f2', name: 'Silk Slip Dress',  brand: 'Atelier', imageUrl: 'https://picsum.photos/seed/f2/600/800',
    price: 4299, comparePrice: 6499, badge: '-34%'),
  const Product(id: 'f3', name: 'Wide Leg Jeans',   brand: 'Denim Co', imageUrl: 'https://picsum.photos/seed/f3/600/800',
    price: 2899, comparePrice: 4999, badge: '-42%'),
  const Product(id: 'f4', name: 'Oversized Blazer', brand: 'Studio',   imageUrl: 'https://picsum.photos/seed/f4/600/800',
    price: 5499, comparePrice: 8999, badge: '-39%'),
  const Product(id: 'f5', name: 'Linen Shirt',      brand: 'Nordic',   imageUrl: 'https://picsum.photos/seed/f5/600/800',
    price: 1899, comparePrice: 3499, badge: '-46%'),
];

final List<Product> mockNewArrivals = [
  const Product(id: 'n1', name: 'Pleated Midi Skirt',   brand: 'Richiva', imageUrl: 'https://picsum.photos/seed/n1/600/800', price: 4299, badge: 'New'),
  const Product(id: 'n2', name: 'Ribbed Knit Top',      brand: 'Atelier', imageUrl: 'https://picsum.photos/seed/n2/600/800', price: 2199, badge: 'New'),
  const Product(id: 'n3', name: 'Structured Tote',      brand: 'Studio',  imageUrl: 'https://picsum.photos/seed/n3/600/800', price: 6899, badge: 'New'),
  const Product(id: 'n4', name: 'Leather Loafers',      brand: 'Nordic',  imageUrl: 'https://picsum.photos/seed/n4/600/800', price: 7499, badge: 'New'),
  const Product(id: 'n5', name: 'Cotton Poplin Shirt',  brand: 'Richiva', imageUrl: 'https://picsum.photos/seed/n5/600/800', price: 2499, badge: 'New'),
];

final List<Product> mockTrending = [
  const Product(id: 't1', name: 'Cropped Cardigan',  brand: 'Studio',  imageUrl: 'https://picsum.photos/seed/t1/600/800', price: 3299),
  const Product(id: 't2', name: 'Wide Brim Hat',     brand: 'Atelier', imageUrl: 'https://picsum.photos/seed/t2/600/800', price: 1899),
  const Product(id: 't3', name: 'Chunky Sneakers',   brand: 'Nordic',  imageUrl: 'https://picsum.photos/seed/t3/600/800', price: 5999),
  const Product(id: 't4', name: 'Gold Hoop Earrings',brand: 'Richiva', imageUrl: 'https://picsum.photos/seed/t4/600/800', price: 1499),
  const Product(id: 't5', name: 'Silk Scarf',        brand: 'Atelier', imageUrl: 'https://picsum.photos/seed/t5/600/800', price: 2199),
];

final List<Map<String, dynamic>> mockCollections = [
  {
    'id': 'summer-essentials',
    'title': 'Summer Essentials',
    'subtitle': '22 pieces',
    'imageUrl': 'https://picsum.photos/seed/col1/800/1000',
  },
  {
    'id': 'office-edit',
    'title': 'Office Edit',
    'subtitle': '18 pieces',
    'imageUrl': 'https://picsum.photos/seed/col2/800/1000',
  },
  {
    'id': 'evening-wear',
    'title': 'Evening Wear',
    'subtitle': '14 pieces',
    'imageUrl': 'https://picsum.photos/seed/col3/800/1000',
  },
  {
    'id': 'weekend-casual',
    'title': 'Weekend Casual',
    'subtitle': '26 pieces',
    'imageUrl': 'https://picsum.photos/seed/col4/800/1000',
  },
];

final List<Product> mockRecentlyViewed = [
  const Product(id: 'r1', name: 'Wrap Midi Dress',   brand: 'Richiva', imageUrl: 'https://picsum.photos/seed/r1/600/800', price: 4899),
  const Product(id: 'r2', name: 'Straight Leg Pants',brand: 'Studio',  imageUrl: 'https://picsum.photos/seed/r2/600/800', price: 3699),
  const Product(id: 'r3', name: 'Cropped Denim Jacket',brand: 'Denim Co', imageUrl: 'https://picsum.photos/seed/r3/600/800', price: 5499),
];

/// Returns all products across all lists, deduped by id.
List<Product> get allMockProducts {
  final seen = <String>{};
  final out = <Product>[];
  for (final list in [
    mockFlashSale,
    mockNewArrivals,
    mockTrending,
    mockRecentlyViewed,
  ]) {
    for (final p in list) {
      if (seen.add(p.id)) out.add(p);
    }
  }
  return out;
}

/// Products to display for a category slug.
/// We don't have a category field on Product yet — honest fallback:
///   - 'sale' → only on-sale products
///   - anything else → full catalog
/// Optional `sub` applies a case-insensitive name/brand match.
List<Product> productsForCategory(String slug, {String? sub}) {
  var list = allMockProducts;

  if (slug.toLowerCase() == 'sale') {
    list = list.where((p) => p.isOnSale).toList();
  }

  if (sub != null && sub.isNotEmpty) {
    final needle = sub.toLowerCase();
    list = list
        .where((p) =>
            p.name.toLowerCase().contains(needle) ||
            p.brand.toLowerCase().contains(needle))
        .toList();
  }

  return list;
}

/// Look up a collection record by id. Returns null if not found.
Map<String, dynamic>? collectionById(String id) {
  try {
    return mockCollections.firstWhere((c) => c['id'] == id);
  } catch (_) {
    return null;
  }
}

/// Subcategories per category slug (used by Categories + Shop screens).
const Map<String, List<String>> kSubcategories = {
  'women':   ['Dresses', 'Tops', 'Bottoms', 'Outerwear', 'Knitwear'],
  'men':     ['Shirts', 'T-Shirts', 'Jeans', 'Jackets', 'Suits'],
  'kids':    ['Boys', 'Girls', 'Baby', 'School'],
  'shoes':   ['Sneakers', 'Boots', 'Sandals', 'Heels', 'Loafers'],
  'bags':    ['Totes', 'Crossbody', 'Clutches', 'Backpacks'],
  'beauty':  ['Skincare', 'Makeup', 'Fragrance', 'Hair'],
  'jewelry': ['Earrings', 'Necklaces', 'Bracelets', 'Rings'],
  'sale':    ['Under Rs. 2000', 'Clearance', 'Last Chance'],
};

/// Human-readable title for a category slug (e.g. 'women' -> 'Women').
String categoryTitle(String slug) {
  if (slug.isEmpty) return 'Shop';
  return slug[0].toUpperCase() + slug.substring(1).replaceAll('-', ' ');
}

// ─────────────────────────────────────────────────────────────────────────────
// Product detail lookup — used by /product/:id
// ─────────────────────────────────────────────────────────────────────────────

Product? _findBase(String id) {
  for (final list in [mockFlashSale, mockNewArrivals, mockTrending, mockRecentlyViewed]) {
    for (final p in list) {
      if (p.id == id) return p;
    }
  }
  return null;
}

/// Enriches a base product with gallery images, sizes, colors, description.
/// Falls back to a sensible placeholder if the id isn't found.
Product mockProductDetail(String id) {
  final base = _findBase(id) ??
      Product(
        id: id,
        name: 'Signature Piece',
        brand: 'Richiva',
        imageUrl: 'https://picsum.photos/seed/$id/600/800',
        price: 3999,
      );

  return Product(
    id: base.id,
    name: base.name,
    brand: base.brand,
    imageUrl: base.imageUrl,
    price: base.price,
    comparePrice: base.comparePrice,
    badge: base.badge,
    images: [
      base.imageUrl,
      'https://picsum.photos/seed/${id}a/600/800',
      'https://picsum.photos/seed/${id}b/600/800',
      'https://picsum.photos/seed/${id}c/600/800',
    ],
    sizes: const ['XS', 'S', 'M', 'L', 'XL'],
    colors: const ['Black', 'Beige', 'White', 'Navy'],
    description:
        'Crafted from premium materials, this ${base.name.toLowerCase()} from '
        '${base.brand} is designed for the modern wardrobe. Tailored fit, '
        'breathable fabric, and a timeless silhouette that moves with you.',
    rating: 4.6,
    reviewCount: 128,
  );
}