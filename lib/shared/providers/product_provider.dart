import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/product.dart';

final apiClientProvider = Provider((ref) => ApiClient());

final newArrivalsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final api = ref.watch(apiClientProvider);
  await Future.delayed(const Duration(seconds: 2));
  final rawData = await api.getProducts();
  return rawData.take(5).map((json) {
    return Product(
      id: json['id'].toString(),
      name: 'Dynamic Product ${json['id']}',
      brand: 'Richiva API',
      imageUrl: 'https://picsum.photos/seed/${json['id']}/600/800',
      price: 2500 + (json['id'] * 100),
      comparePrice: 4000,
      badge: 'API',
    );
  }).toList();
});

final productDetailProvider = FutureProvider.autoDispose.family<Product, String>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  await Future.delayed(const Duration(seconds: 2));
  final json = await api.getProduct(id);
  return Product(
    id: id,
    name: 'Dynamic ${json['title'].toString().substring(0, 15)}...',
    brand: 'Richiva API',
    imageUrl: 'https://picsum.photos/seed/$id/600/800',
    price: 3500,
    comparePrice: 5000,
    description: json['body'] ?? 'No description available.',
    images: [
      'https://picsum.photos/seed/$id-a/600/800',
      'https://picsum.photos/seed/$id-b/600/800',
      'https://picsum.photos/seed/$id-c/600/800',
    ],
    sizes: const ['S', 'M', 'L', 'XL'],
    colors: const ['Black', 'White', 'Navy'],
  );
});