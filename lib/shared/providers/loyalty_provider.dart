import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../persistence/persisted_notifier.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tiers
// ─────────────────────────────────────────────────────────────────────────────
enum LoyaltyTier {
  bronze(0, 'Bronze'),
  silver(1000, 'Silver'),
  gold(5000, 'Gold'),
  platinum(15000, 'Platinum');

  final int minPoints;
  final String label;
  const LoyaltyTier(this.minPoints, this.label);

  static LoyaltyTier fromPoints(int p) {
    if (p >= platinum.minPoints) return platinum;
    if (p >= gold.minPoints) return gold;
    if (p >= silver.minPoints) return silver;
    return bronze;
  }

  LoyaltyTier? get next {
    switch (this) {
      case bronze:   return silver;
      case silver:   return gold;
      case gold:     return platinum;
      case platinum: return null;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Earning history
// ─────────────────────────────────────────────────────────────────────────────
class PointEntry {
  final String reason;
  final int points; // positive = earned, negative = redeemed
  final DateTime timestamp;
  const PointEntry({
    required this.reason,
    required this.points,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'reason': reason,
        'points': points,
        'timestamp': timestamp.toIso8601String(),
      };

  static PointEntry fromJson(Map<String, dynamic> j) => PointEntry(
        reason: j['reason'] as String,
        points: j['points'] as int,
        timestamp: DateTime.parse(j['timestamp'] as String),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────
class LoyaltyState {
  final int points;
  final List<PointEntry> history;

  const LoyaltyState({required this.points, required this.history});

  LoyaltyTier get tier => LoyaltyTier.fromPoints(points);

  /// Progress (0.0–1.0) toward the next tier. 1.0 for platinum.
  double get progressToNext {
    final next = tier.next;
    if (next == null) return 1.0;
    final start = tier.minPoints;
    final end = next.minPoints;
    return ((points - start) / (end - start)).clamp(0.0, 1.0);
  }

  /// Points remaining to hit the next tier. 0 for platinum.
  int get pointsToNext {
    final next = tier.next;
    if (next == null) return 0;
    return (next.minPoints - points).clamp(0, 1 << 30);
  }

  LoyaltyState copyWith({int? points, List<PointEntry>? history}) =>
      LoyaltyState(
        points: points ?? this.points,
        history: history ?? this.history,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────
class LoyaltyNotifier extends PersistedNotifier<LoyaltyState> {
  LoyaltyNotifier()
      : super(
          storageKey: 'richiva.loyalty.v1',
          seed: LoyaltyState(points: 3450, history: _seedHistory()),
        );

  static List<PointEntry> _seedHistory() {
    final now = DateTime.now();
    return [
      PointEntry(
        reason: 'Order ORD-2400 delivered',
        points: 439,
        timestamp: now.subtract(const Duration(days: 12)),
      ),
      PointEntry(
        reason: 'Order ORD-2388 delivered',
        points: 289,
        timestamp: now.subtract(const Duration(days: 28)),
      ),
      PointEntry(
        reason: 'Referral bonus',
        points: 500,
        timestamp: now.subtract(const Duration(days: 40)),
      ),
      PointEntry(
        reason: 'Redeemed for voucher',
        points: -1000,
        timestamp: now.subtract(const Duration(days: 55)),
      ),
      PointEntry(
        reason: 'Welcome bonus',
        points: 200,
        timestamp: now.subtract(const Duration(days: 90)),
      ),
    ];
  }

  @override
  dynamic serialize(LoyaltyState state) => {
        'points': state.points,
        'history': state.history
            .map((e) => e.toJson())
            .toList(),
      };

  @override
  LoyaltyState deserialize(dynamic json) {
    final map = json as Map<String, dynamic>;
    return LoyaltyState(
      points: map['points'] as int,
      history: (map['history'] as List)
          .map((e) => PointEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  void earn({required int points, required String reason}) {
    final entry =
        PointEntry(reason: reason, points: points, timestamp: DateTime.now());
    state = state.copyWith(
      points: state.points + points,
      history: [entry, ...state.history],
    );
  }

  /// Returns null on success, or an error string if the user can't afford it.
  String? redeem({required int points, required String reason}) {
    if (points <= 0) return 'Invalid amount';
    if (state.points < points) return 'Not enough points';
    final entry =
        PointEntry(reason: reason, points: -points, timestamp: DateTime.now());
    state = state.copyWith(
      points: state.points - points,
      history: [entry, ...state.history],
    );
    return null;
  }
}

final loyaltyProvider =
    StateNotifierProvider<LoyaltyNotifier, LoyaltyState>((_) => LoyaltyNotifier());