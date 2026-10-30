import 'package:flutter/material.dart';

class AiScreen extends StatelessWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Center(
        child: Text('AI Assistant', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}