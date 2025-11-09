import 'package:freezed_annotation/freezed_annotation.dart';

part 'paged_dto.freezed.dart';

/// DTO genérico para respuestas paginadas del backend
///
/// Estructura estándar de Django REST Framework:
/// {
///   "count": 100,
///   "next": "http://api.com/users/?page=3",
///   "previous": "http://api.com/users/?page=1",
///   "results": [...]
/// }
@Freezed(genericArgumentFactories: true)
class PagedDto<T> with _$PagedDto<T> {
  const factory PagedDto({
    required int count,
    String? next,
    String? previous,
    required List<T> results,
  }) = _PagedDto<T>;

  factory PagedDto.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) {
    return PagedDto<T>(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
