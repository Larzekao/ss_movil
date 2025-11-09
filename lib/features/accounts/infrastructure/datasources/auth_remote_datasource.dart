import 'package:dio/dio.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/login_response_dto.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/refresh_response_dto.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/user_dto.dart';

/// DataSource remoto para autenticación (Infrastructure)
class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  /// POST /auth/login/
  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login/',
      data: {'email': email, 'password': password},
    );

    return LoginResponseDto.fromJson(response.data);
  }

  /// POST /auth/register/register/
  Future<UserDto> register({
    required String email,
    required String password,
    required String passwordConfirm,
    required String nombre,
    required String apellido,
    String? telefono,
  }) async {
    final response = await _dio.post(
      '/auth/register/register/',
      data: {
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
        'nombre': nombre,
        'apellido': apellido,
        if (telefono != null) 'telefono': telefono,
      },
    );

    // El backend retorna { message: "...", user: {...} }
    return UserDto.fromJson(response.data['user']);
  }

  /// GET /auth/users/me/
  Future<UserDto> me() async {
    final response = await _dio.get('/auth/users/me/');
    return UserDto.fromJson(response.data);
  }

  /// POST /auth/refresh/
  Future<RefreshResponseDto> refresh({required String refreshToken}) async {
    final response = await _dio.post(
      '/auth/refresh/',
      data: {'refresh': refreshToken},
    );

    return RefreshResponseDto.fromJson(response.data);
  }
}
