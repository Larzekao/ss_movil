import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_movil/core/providers/app_providers.dart';
import 'package:ss_movil/features/accounts/domain/entities/role.dart';
import 'package:ss_movil/features/accounts/infrastructure/dtos/role_dto.dart';

/// Provider para obtener la lista de todos los roles
final rolesListProvider = FutureProvider<List<Role>>((ref) async {
  final dioClient = ref.read(dioClientProvider);

  try {
    final response = await dioClient.client.get(
      'http://10.0.2.2:8000/api/auth/roles/',
    );

    if (response.statusCode == 200) {
      final data = response.data;

      // Si la respuesta tiene paginación
      if (data is Map && data.containsKey('results')) {
        final results = data['results'] as List;
        return results.map((roleJson) {
          final dto = RoleDto.fromJson(roleJson as Map<String, dynamic>);
          return dto.toEntity();
        }).toList();
      }

      // Si es una lista directa
      if (data is List) {
        return data.map((roleJson) {
          final dto = RoleDto.fromJson(roleJson as Map<String, dynamic>);
          return dto.toEntity();
        }).toList();
      }
    }

    throw Exception('Error al cargar roles');
  } catch (e) {
    throw Exception('Error al cargar roles: $e');
  }
});
