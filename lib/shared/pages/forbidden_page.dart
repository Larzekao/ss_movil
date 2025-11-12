import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Página que se muestra cuando el usuario no tiene permiso para acceder a un recurso
class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acceso Denegado'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de candado
            Icon(Icons.lock_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 24),

            // Título
            Text(
              '403 - Acceso Denegado',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'No tienes permisos para acceder a este recurso',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 32),

            // Botón volver
            ElevatedButton.icon(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
