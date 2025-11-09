import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/user_dto.dart';

part 'login_response_dto.freezed.dart';
part 'login_response_dto.g.dart';

/// DTO para respuesta de Login (Infrastructure)
@freezed
class LoginResponseDto with _$LoginResponseDto {
  const factory LoginResponseDto({
    required String access,
    required String refresh,
    required UserDto user,
  }) = _LoginResponseDto;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);
}
