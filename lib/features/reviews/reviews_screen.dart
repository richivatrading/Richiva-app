import 'package:flutter/material.dart';

class ReviewsScreen extends StatelessWidget {
  final String id;
  const ReviewsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: Center(
        child: Text('Reviews $id', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}