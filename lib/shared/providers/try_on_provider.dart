import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TryOnGarment {
  summerDress('Summer Dress', 'https://picsum.photos/seed/dress/400/500'),
  cashmereSweater('Cashmere Sweater', 'https://picsum.photos/seed/sweater/400/500'),
  wideLegJeans('Wide Leg Jeans', 'https://picsum.photos/seed/jeans/400/500'),
  oversizedBlazer('Oversized Blazer', 'https://picsum.photos/seed/blazer/400/500');

  const TryOnGarment(this.displayName, this.imageUrl);

  final String displayName;
  final String imageUrl;
}

class TryOnState {
  final bool initialized;
  final TryOnGarment? selectedGarment;
  final bool isCameraActive;
  final String? cameraError;

  const TryOnState({
    this.initialized = false,
    this.selectedGarment,
    this.isCameraActive = false,
    this.cameraError,
  });

  TryOnState copyWith({
    bool? initialized,
    TryOnGarment? selectedGarment,
    bool? isCameraActive,
    String? cameraError,
  }) {
    return TryOnState(
      initialized: initialized ?? this.initialized,
      selectedGarment: selectedGarment ?? this.selectedGarment,
      isCameraActive: isCameraActive ?? this.isCameraActive,
      cameraError: cameraError ?? this.cameraError,
    );
  }
}

class TryOnNotifier extends StateNotifier<TryOnState> {
  TryOnNotifier() : super(const TryOnState());

  Future<void> initialize() async {
    state = state.copyWith(
      initialized: true,
      selectedGarment: TryOnGarment.summerDress,
    );
  }

  void selectGarment(TryOnGarment garment) {
    state = state.copyWith(selectedGarment: garment);
  }

  void setCameraActive(bool active) {
    state = state.copyWith(isCameraActive: active);
  }

  void setCameraError(String? error) {
    state = state.copyWith(cameraError: error);
  }
}

final tryOnProvider =
    StateNotifierProvider<TryOnNotifier, TryOnState>((ref) => TryOnNotifier());