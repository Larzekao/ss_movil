import 'package:freezed_annotation/freezed_annotation.dart';

part 'paged_dto.freezed.dart';
part 'paged_dto.g.dart';

/// DTO genérico para respuestas paginadas (Infrastructure)
@Freezed(genericArgumentFactories: true)
class PagedDto<T> with _$PagedDto<T> {
  const factory PagedDto({
    required int count,
    String? next,
    String? previous,
    required List<T> results,
  }) = _PagedDto<T>;

  const PagedDto._();

  factory PagedDto.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PagedDtoFromJson(json, fromJsonT);
}
