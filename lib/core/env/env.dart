import 'package:flutter/services.dart';

/// Clase para gestionar variables de entorno (.env.dev / .env.prod)
/// Uso: await Env.load(); y luego Env.apiBaseUrl
class Env {
  static late String apiBaseUrl;

  /// Carga el archivo .env según el entorno (dev por defecto)
  static Future<void> load({String env = 'dev'}) async {
    try {
      final envFile = '.env.$env';
      final contents = await rootBundle.loadString(envFile);

      // Parsear línea por línea
      for (var line in contents.split('\n')) {
        line = line.trim();
        if (line.isEmpty || line.startsWith('#')) continue;

        final parts = line.split('=');
        if (parts.length == 2) {
          final key = parts[0].trim();
          final value = parts[1].trim();

          if (key == 'API_BASE_URL') {
            apiBaseUrl = value;
          }
        }
      }
    } catch (e) {
      throw Exception('Error cargando archivo .env.$env: $e');
    }
  }
}
