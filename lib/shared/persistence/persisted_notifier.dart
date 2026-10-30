import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base class for StateNotifier subclasses that persist to
/// SharedPreferences.
///
/// Subclasses only need to:
///   1. Call `super(storageKey: kXxxKey, seed: ...)` from their constructor
///   2. Override `serialize(state)` → JSON-encodable dynamic
///   3. Override `deserialize(json)` → T
///
/// All state changes are automatically saved (debounced 250ms). Loading
/// happens asynchronously in the background; state shows `seed` until
/// the saved payload arrives, then is replaced.
abstract class PersistedNotifier<T> extends StateNotifier<T> {
  final String storageKey;
  final T seed;

  bool _loaded = false;
  bool _userMutated = false;
  bool _skipNextPersist = false;
  Timer? _debounce;

  PersistedNotifier({
    required this.storageKey,
    required this.seed,
  }) : super(seed) {
    _restore();
  }

  // ── Subclass hooks ─────────────────────────────────────────────────────
  dynamic serialize(T state);
  T deserialize(dynamic json);

  // ── State change handler ───────────────────────────────────────────────
  @override
  set state(T newState) {
    if (!_loaded) {
      _userMutated = true;
      super.state = newState;
      return;
    }
    if (_skipNextPersist) {
      super.state = newState;
      return;
    }
    super.state = newState;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _flush);
  }

  // ── Load from disk ─────────────────────────────────────────────────────
  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(storageKey);

      // If user already mutated state before we loaded, don't override.
      if (_userMutated) {
        _loaded = true;
        _flush();
        return;
      }

      if (raw == null) {
        _loaded = true;
        return;
      }

      final json = jsonDecode(raw);
      _loaded = true;
      _skipNextPersist = true;
      try {
        state = deserialize(json);
      } finally {
        _skipNextPersist = false;
      }
    } catch (_) {
      _loaded = true;
    }
  }

  // ── Save to disk ───────────────────────────────────────────────────────
  Future<void> _flush() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(storageKey, jsonEncode(serialize(state)));
    } catch (_) {}
  }

  /// Force immediate save (call before app pause, or on critical events).
  Future<void> persistNow() {
    _debounce?.cancel();
    return _flush();
  }

  /// Clear saved data and reset to seed.
  Future<void> resetToSeed() async {
    _debounce?.cancel();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey);
    } catch (_) {}
    _skipNextPersist = true;
    state = seed;
    _skipNextPersist = false;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Central key registry + reset helper
// ─────────────────────────────────────────────────────────────────────────────
const kBagKey = 'richiva.bag.v1';
const kOrdersKey = 'richiva.orders.v1';
const kWishlistKey = 'richiva.wishlist.v1';
const kUserKey = 'richiva.user.v1';
const kLoyaltyKey = 'richiva.loyalty.v1';
const kReviewsKey = 'richiva.reviews.v1';
const kRecentlyViewedKey = 'richiva.recentlyViewed.v1';
const kNotificationsKey = 'richiva.notifications.v1';
const kNotificationSettingsKey = 'richiva.notification_settings.v1';
const kVoucherCatalogKey = 'richiva.voucherCatalog.v1';

const kAllPersistenceKeys = [
  kBagKey,
  kOrdersKey,
  kWishlistKey,
  kUserKey,
  kLoyaltyKey,
  kReviewsKey,
  kRecentlyViewedKey,
  kNotificationsKey,
  kNotificationSettingsKey,
  kVoucherCatalogKey,
];

/// Wipes all persisted app data. Useful in a "reset demo" settings entry
/// or during testing.
Future<void> resetAllPersistence() async {
  final prefs = await SharedPreferences.getInstance();
  for (final key in kAllPersistenceKeys) {
    await prefs.remove(key);
  }
}