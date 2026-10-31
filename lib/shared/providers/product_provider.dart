import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/product.dart';

final apiClientProvider = Provider((ref) => ApiClient());

final newArrivalsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  return await ref.watch(apiClientProvider).getProducts();
});

final productDetailProvider =
    FutureProvider.autoDispose.family<Product, String>((ref, id) async {
  return await ref.watch(apiClientProvider).getProduct(id);
});