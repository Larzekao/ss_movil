class FavoritesState {
  final List<int> favoriteIds;
  final bool loading;
  final String? error;

  FavoritesState({
    this.favoriteIds = const [],
    this.loading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<int>? favoriteIds,
    bool? loading,
    String? error,
  }) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }

  bool isFavorite(int productId) => favoriteIds.contains(productId);

  @override
  String toString() =>
      'FavoritesState(favoriteIds: ${favoriteIds.length}, loading: $loading, error: $error)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoritesState &&
          runtimeType == other.runtimeType &&
          favoriteIds == other.favoriteIds &&
          loading == other.loading &&
          error == other.error;

  @override
  int get hashCode => favoriteIds.hashCode ^ loading.hashCode ^ error.hashCode;
}
