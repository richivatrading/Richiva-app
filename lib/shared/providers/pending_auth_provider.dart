import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthFlow { login, register, forgot }

class PendingAuth {
  final String contact;
  final String? password;
  final String? name;
  final AuthFlow flow;

  const PendingAuth({
    required this.contact,
    this.password,
    this.name,
    required this.flow,
  });
}

class PendingAuthNotifier extends StateNotifier<PendingAuth?> {
  PendingAuthNotifier() : super(null);

  void set(PendingAuth auth) => state = auth;
  void clear() => state = null;
}

final pendingAuthProvider =
    StateNotifierProvider<PendingAuthNotifier, PendingAuth?>(
  (_) => PendingAuthNotifier(),
);