import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'shared/widgets/persistence_lifecycle_listener.dart';

class RichivaApp extends ConsumerWidget {
  const RichivaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Richiva',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        return PersistenceLifecycleListener(child: child!);
      },
    );
  }
}