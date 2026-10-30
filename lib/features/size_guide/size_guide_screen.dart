import 'package:flutter/material.dart';

class SizeGuideScreen extends StatelessWidget {
  const SizeGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Size Guide')),
      body: Center(
        child: Text('Size Guide', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}