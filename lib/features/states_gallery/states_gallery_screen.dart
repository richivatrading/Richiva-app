import 'package:flutter/material.dart';

class StatesGalleryScreen extends StatelessWidget {
  const StatesGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('States Gallery')),
      body: Center(
        child: Text('States Gallery', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}