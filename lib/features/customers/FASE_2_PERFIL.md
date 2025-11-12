# Fase 2 — Perfil del Cliente ("Mi Cuenta")

## Descripción

Implementación completa de la pantalla de Perfil del cliente con capacidad de edición en tiempo real, integrada con el backend.

## Archivos Creados

### Presentación (Presentation Layer)

#### `presentation/controllers/profile_state.dart`
- **ProfileState**: Estado que mantiene:
  - `me`: Objeto Cliente con datos del usuario
  - `loading`: Boolean para indicar carga
  - `error`: String opcional con mensaje de error
- Incluye `copyWith()` para immutabilidad

#### `presentation/controllers/profile_controller.dart`
- **ProfileController**: StateNotifier de Riverpod que gestiona:
  - `loadMe()`: Carga el perfil del usuario actual desde `/auth/users/me/`
  - `updateProfile(nombre?, telefono?)`: Actualiza datos en `PATCH /customers/perfil/`
  - `clear()`: Limpia el estado
- Proveedores Riverpod:
  - `profileControllerProvider`: Acceso principal al controlador
  - `customersRepositoryProvider`: Inyección del repositorio
  - `getMeUseCaseProvider`: Caso de uso para obtener perfil
  - `updateProfileUseCaseProvider`: Caso de uso para actualizar

#### `presentation/pages/profile_page.dart`
- **ProfilePage**: ConsumerStatefulWidget que:
  - Carga automáticamente el perfil al abrir (`initState`)
  - Muestra avatar, nombre, email, teléfono
  - Modal de edición con validación básica
  - Botón "Cerrar Sesión" que:
    - Borra tokens del secure storage
    - Limpia estado del perfil
    - Redirige a `/login`

### Core (Infraestructura)

#### `core/storage/token_storage.dart`
- **TokenStorage**: Wrapper para FlutterSecureStorage
- Métodos:
  - `setAccessToken(token)`: Guarda access token
  - `setRefreshToken(token)`: Guarda refresh token
  - `getAccessToken()`: Obtiene access token
  - `getRefreshToken()`: Obtiene refresh token
  - `clearTokens()`: Borra ambos tokens
  - `hasValidTokens()`: Verifica si ambos existen

#### `core/providers/dio_provider.dart`
- **Providers Riverpod**:
  - `secureStorageProvider`: FlutterSecureStorage singleton
  - `tokenStorageProvider`: TokenStorage singleton
  - `dioProvider`: Dio configurado con:
    - Base URL: `http://10.0.2.2:8000/api`
    - Interceptor que agrega `Authorization: Bearer <token>`
    - Manejo de 401: Intenta refrescar token automáticamente
    - Si refresh falla: Borra tokens

## Flujo de Autenticación

1. **Solicitud con token expirado (401)**
   - Interceptor lo detecta
   - Envía POST `/auth/refresh/` con refresh token
   - Obtiene nuevo access token
   - Reintenta solicitud original una sola vez

2. **Si refresh falla o no hay refresh token**
   - Borra access y refresh tokens
   - Error se propaga al controlador

## Criterios de Aceptación

✅ Al abrir "Mi Cuenta":
- Se ejecuta `loadMe()` automáticamente
- Se muestra el perfil: email, nombre, teléfono
- Estado `loading: true` mientras carga

✅ Editar Perfil:
- Modal con campos nombre y teléfono
- Validación mínima (no vacíos si se editan)
- POST/PATCH a backend
- Cambios reflejados sin recargar la app

✅ Cerrar Sesión:
- Confirmación de diálogo
- Borra tokens de secure storage
- Limpia estado
- Redirige a `/login`

## Próximos Pasos

- Añadir vista de direcciones (addresses_page.dart)
- Implementar preferencias (idioma, notificaciones)
- Agregar foto de perfil/avatar
- Integrar con GoRouter para rutas

## Testing Manual

```dart
// Para probar el flujo:
1. Navegar a /profile
2. Esperar carga de datos
3. Ver email, nombre, teléfono
4. Click "Editar Perfil"
5. Cambiar nombre/teléfono
6. Guardar y verificar actualización
7. Click "Cerrar Sesión"
8. Confirmar redirección a /login
```
