import 'package:flutter/material.dart';

class CollectionScreen extends StatelessWidget {
  final String id;
  const CollectionScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collection')),
      body: Center(
        child: Text('Collection $id', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}