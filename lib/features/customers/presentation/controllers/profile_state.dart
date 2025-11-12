import 'package:ss_movil/features/customers/domain/entities/cliente.dart';

class ProfileState {
  final Cliente? me;
  final bool loading;
  final String? error;

  ProfileState({this.me, this.loading = false, this.error});

  ProfileState copyWith({Cliente? me, bool? loading, String? error}) {
    return ProfileState(
      me: me ?? this.me,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }

  @override
  String toString() =>
      'ProfileState(me: $me, loading: $loading, error: $error)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileState &&
          runtimeType == other.runtimeType &&
          me == other.me &&
          loading == other.loading &&
          error == other.error;

  @override
  int get hashCode => me.hashCode ^ loading.hashCode ^ error.hashCode;
}
