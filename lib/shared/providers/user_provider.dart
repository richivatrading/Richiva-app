import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../persistence/persisted_notifier.dart';

class User {
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime memberSince;

  const User({
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.memberSince,
  });

  User copyWith({String? name, String? email, String? avatarUrl}) => User(
        name: name ?? this.name,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        memberSince: memberSince,
      );

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'memberSince': memberSince.toIso8601String(),
      };

  static User fromJson(Map<String, dynamic> j) => User(
        name: j['name'] as String,
        email: j['email'] as String,
        avatarUrl: j['avatarUrl'] as String?,
        memberSince: DateTime.parse(j['memberSince'] as String),
      );
}

class UserNotifier extends PersistedNotifier<User?> {
  UserNotifier()
      : super(
          storageKey: 'richiva.user.v1',
          seed: User(
            name: 'Aarav Sharma',
            email: 'aarav.sharma@example.com',
            memberSince: DateTime(2024, 3, 12),
          ),
        );

  @override
  dynamic serialize(User? state) {
    // Distinguishes "signed out" from "never signed in".
    if (state == null) return {'__signedOut': true};
    return state.toJson();
  }

  @override
  User? deserialize(dynamic json) {
    final map = json as Map<String, dynamic>;
    if (map['__signedOut'] == true) return null;
    return User.fromJson(map);
  }

  void update(User u) => state = u;
  void signOut() => state = null;
  void signIn(User u) => state = u;
}

final userProvider =
    StateNotifierProvider<UserNotifier, User?>((ref) => UserNotifier());