# Flutter App - Arquitectura Clean Architecture (Fases 1-3)

## Resumen General

Se ha implementado una arquitectura completa y escalable para la aplicación móvil Flutter siguiendo **Clean Architecture** con **Riverpod** como gestor de estado. El proyecto está dividido en 4 fases implementadas:

- **Fase 1**: Estructura de capas (Domain, Infrastructure, Application)
- **Fase 2**: Perfil del cliente ("Mi Cuenta")
- **Fase 3**: Gestión de direcciones (CRUD + principal)
- **Fase 4**: Preferencias del usuario (auto-save con debounce)

## Estructura de Carpetas

```
lib/
├── core/
│   ├── exceptions/
│   │   └── app_exceptions.dart          # Excepciones personalizadas
│   ├── providers/
│   │   └── dio_provider.dart            # Configuración Dio con interceptores
│   └── storage/
│       └── token_storage.dart           # Gestión de tokens en secure storage
│
├── features/
│   └── customers/
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── cliente.dart
│       │   │   ├── direccion.dart
│       │   │   └── preferencias.dart
│       │   └── repositories/
│       │       └── customers_repository.dart  # Contrato/interfaz
│       │
│       ├── infrastructure/
│       │   ├── datasources/
│       │   │   └── customers_remote_datasource.dart  # Llamadas HTTP
│       │   ├── models/
│       │   │   ├── cliente_dto.dart
│       │   │   ├── direccion_dto.dart
│       │   │   └── preferencias_dto.dart
│       │   └── repositories/
│       │       └── customers_repository_impl.dart    # Implementación
│       │
│       ├── application/
│       │   └── usecases/
│       │       ├── list_addresses_usecase.dart
│       │       ├── create_address_usecase.dart
│       │       ├── update_address_usecase.dart
│       │       ├── delete_address_usecase.dart
│       │       ├── set_principal_address_usecase.dart
│       │       ├── get_me_usecase.dart
│       │       ├── update_profile_usecase.dart
│       │       ├── get_preferences_usecase.dart
│       │       ├── update_preferences_usecase.dart
│       │       ├── list_favorites_usecase.dart
│       │       └── toggle_favorite_usecase.dart
│       │
│       └── presentation/
│           ├── controllers/
│           │   ├── profile_state.dart
│           │   ├── profile_controller.dart
│           │   ├── addresses_state.dart
│           │   └── addresses_controller.dart
│           └── pages/
│               ├── profile_page.dart
│               └── addresses_page.dart
│
├── app.dart                            # Configuración GoRouter
└── main.dart                           # Entry point
```

## Capas de Arquitectura

### 1. Domain Layer (Lógica de Negocio)
- **Entities**: Clases inmutables que representan conceptos del negocio
- **Repositories**: Interfaces que definen contratos sin detalles de implementación

### 2. Infrastructure Layer (Acceso a Datos)
- **DataSources**: Conexión con APIs (Dio)
- **DTOs**: Data Transfer Objects con `fromJson`/`toJson`/`toEntity`
- **Repository Implementation**: Implementa contratos del Domain usando DTOs

### 3. Application Layer (Lógica de Aplicación)
- **Use Cases**: Cada caso de uso es una clase con lógica específica
- Separa responsabilidades y facilita testing

### 4. Presentation Layer (UI)
- **Controllers**: StateNotifier de Riverpod que gestiona estado
- **Pages**: UI que consume controllers a través de providers
- **States**: Objetos inmutables que representan estado de UI

## Tecnologías Utilizadas

- **Flutter**: Framework móvil
- **Riverpod**: Gestor de estado (inyección de dependencias + state management)
- **Dio**: Cliente HTTP con interceptores
- **flutter_secure_storage**: Almacenamiento seguro de tokens
- **go_router**: Navegación declarativa
- **Sin code generation**: No se usa freezed, json_serializable, etc.

## Flujos Principales

### Flujo de Autenticación (Interceptor Dio)

```
Solicitud HTTP
    ↓
Interceptor agrega token: Authorization: Bearer <access>
    ↓
Si 401 (Unauthorized):
    → POST /auth/refresh/ con refresh token
    → Obtiene nuevo access token
    → Reintenta solicitud original
    → Si falla: borra tokens → error
```

### Flujo de Perfil

```
ProfilePage
    ↓ initState
Riverpod: ref.read(profileControllerProvider.notifier).loadMe()
    ↓
ProfileController.loadMe()
    ↓ GetMeUseCase
CustomersRepository.getMe()
    ↓ CustomersRemoteDatasource
GET /auth/users/me/
    ↓
ClienteDto.toEntity()
    ↓
ProfileState.me = Cliente (actualiza UI)
```

### Flujo de Direcciones con Optimistic Update

```
Usuario selecciona dirección como principal
    ↓
AddressesController.setPrincipal(id) - OPTIMISTIC
    → Actualiza UI inmediatamente
    ↓
Backend: POST /customers/direcciones/{id}/set-principal/
    ↓ OK: UI correcta
    ✗ Error: Recarga lista desde backend (revierte cambios)
```

## Gestión de Estado (Riverpod)

### Providers Principales

```dart
// Core
final dioProvider = Provider<Dio>
final tokenStorageProvider = Provider<TokenStorage>

// Customers
final customersRepositoryProvider = Provider<CustomersRepository>
final profileControllerProvider = StateNotifierProvider<ProfileController, ProfileState>
final addressesControllerProvider = StateNotifierProvider<AddressesController, AddressesState>
```

### Acceso desde UI

```dart
// Consumir estado
final profileState = ref.watch(profileControllerProvider);

// Ejecutar acción
await ref.read(profileControllerProvider.notifier).loadMe();
```

## Manejo de Errores

1. **Excepciones personalizadas** en `core/exceptions/`:
   - `NetworkException`: Problemas de conectividad
   - `UnauthorizedException`: Token expirado/inválido
   - `NotFoundException`: Recurso no existe
   - `ValidationException`: Error de validación
   - `ServerException`: Error del servidor (5xx)
   - `CacheException`: Error de almacenamiento
   - `UnknownException`: Error desconocido

2. **Mapeo en DataSource**: DioException → AppException

3. **Propagación a UI**: ProfileState.error → Mostrar SnackBar/ErrorCard

## Validación

- **Nivel de DataSource**: Mapeo de excepciones Dio
- **Nivel de UI**: Validación de formularios antes de enviar
  - Campos no vacíos
  - Longitud mínima/máxima
  - Formato de email, teléfono, etc.

## Inyección de Dependencias

Todos los servicios se instancian a través de **Riverpod Providers**:

```dart
// Automática: cuando se necesita Dio, Riverpod lo provee
// Singleton: solo una instancia en toda la app
// Testeable: fácil de mockear providers
```

## Testing (Preparado para)

```dart
// Mockear providers en tests
testWidgets('ProfilePage carga datos', (tester) async {
  const mockClient = dioProvider.overrideWithValue(mockDio);
  // ...
});
```

## Seguridad

✅ Tokens almacenados en **FlutterSecureStorage** (nativo del SO)
✅ Refresh automático sin intervención del usuario
✅ Limpieza de tokens en logout
✅ Bearer token en todas las solicitudes

## Performance

✅ **Optimistic Updates**: Cambios visuales inmediatos
✅ **Lazy Loading**: Solo carga datos cuando se abren páginas
✅ **Providers Cached**: Riverpod cachea resultados hasta invalidearse
✅ **DTOs Ligeros**: Conversión rápida entity ↔ DTO

## Escalabilidad

La arquitectura permite fácil expansión:

```
// Para agregar nueva feature (ej: Orders):
1. Crear domain/entities/orden.dart
2. Crear domain/repositories/orders_repository.dart
3. Crear infrastructure/datasources/orders_remote_datasource.dart
4. Crear infrastructure/repositories/orders_repository_impl.dart
5. Crear application/usecases/*.dart
6. Crear presentation/controllers/orders_controller.dart
7. Crear presentation/pages/orders_page.dart

Cada capa es independiente y reutilizable.
```

## Próximos Pasos

1. **Fase 4**: Autenticación (Login/Register)
2. **Fase 5**: Productos (listado + detalle)
3. **Fase 6**: Carrito de compras
4. **Fase 7**: Órdenes/Pedidos
5. **Fase 8**: Preferencias de cliente

## Referencias

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Documentation](https://riverpod.dev)
- [Dio HTTP Client](https://pub.dev/packages/dio)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
