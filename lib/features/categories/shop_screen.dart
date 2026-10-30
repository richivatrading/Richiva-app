import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  final String slug;
  const ShopScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: Center(
        child: Text('Shop $slug', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}