import 'package:ss_movil/features/customers/domain/entities/preferencias.dart';

class PreferencesState {
  final Preferencias? data;
  final bool loading;
  final String? error;
  final String? successMessage;

  PreferencesState({
    this.data,
    this.loading = false,
    this.error,
    this.successMessage,
  });

  PreferencesState copyWith({
    Preferencias? data,
    bool? loading,
    String? error,
    String? successMessage,
  }) {
    return PreferencesState(
      data: data ?? this.data,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  String toString() =>
      'PreferencesState(data: $data, loading: $loading, error: $error, success: $successMessage)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreferencesState &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          loading == other.loading &&
          error == other.error &&
          successMessage == other.successMessage;

  @override
  int get hashCode =>
      data.hashCode ^
      loading.hashCode ^
      error.hashCode ^
      successMessage.hashCode;
}
