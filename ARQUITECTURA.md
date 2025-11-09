# Arquitectura del Proyecto SS Movil

```
┌─────────────────────────────────────────────────────────────────┐
│                         PRESENTATION                             │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Pages: Splash, Login, Register, Home                   │   │
│  │  Widgets: Can, ProtectedRoute (Fase 1)                  │   │
│  │  State: AuthController (Riverpod)                       │   │
│  └─────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             │ UI Events / State Updates
┌────────────────────────────▼────────────────────────────────────┐
│                         APPLICATION                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  UseCases:                                              │   │
│  │  - LoginUseCase(email, password)                        │   │
│  │  - RegisterUseCase(userData)                            │   │
│  │  - RefreshTokenUseCase()                                │   │
│  │  - GetMeUseCase()                                       │   │
│  │  - LogoutUseCase()                                      │   │
│  └─────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             │ Business Logic
┌────────────────────────────▼────────────────────────────────────┐
│                           DOMAIN                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Entities:                                              │   │
│  │  - User (id, email, nombre, apellido, rol, ...)        │   │
│  │  - Role (id, nombre, permisos)                          │   │
│  │  - Permission (id, codigo, nombre, modulo)             │   │
│  │                                                          │   │
│  │  Repository Interfaces:                                │   │
│  │  - AuthRepository (abstract)                           │   │
│  └─────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             │ Contracts
┌────────────────────────────▼────────────────────────────────────┐
│                       INFRASTRUCTURE                             │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Repository Implementations:                            │   │
│  │  - AuthRepositoryImpl                                   │   │
│  │                                                          │   │
│  │  DataSources:                                           │   │
│  │  - AuthRemoteDataSource (Dio)                           │   │
│  │    • POST /api/auth/login/                              │   │
│  │    • POST /api/auth/register/register/                  │   │
│  │    • POST /api/auth/refresh/                            │   │
│  │    • GET  /api/auth/users/me/                           │   │
│  │                                                          │   │
│  │  DTOs (json_serializable):                              │   │
│  │  - LoginResponseDto                                     │   │
│  │  - UserDto                                              │   │
│  │  - RoleDto, PermissionDto                               │   │
│  └─────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             │ Network Calls
┌────────────────────────────▼────────────────────────────────────┐
│                            CORE                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Network:                                               │   │
│  │  - DioClient (baseURL, timeouts, logging)              │   │
│  │  - AuthInterceptor (inject Bearer, auto-refresh)       │   │
│  │                                                          │   │
│  │  Storage:                                               │   │
│  │  - SecureStorage (tokens JWT)                           │   │
│  │                                                          │   │
│  │  Errors:                                                │   │
│  │  - Failures (Network, Auth, Server, Validation)        │   │
│  │                                                          │   │
│  │  Env:                                                   │   │
│  │  - Env.apiBaseUrl (.env.dev / .env.prod)               │   │
│  │                                                          │   │
│  │  Routes:                                                │   │
│  │  - GoRouter (navigation logic)                         │   │
│  └─────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             │ HTTP/HTTPS
┌────────────────────────────▼────────────────────────────────────┐
│                     BACKEND (Django)                             │
│                   http://10.0.2.2:8000/api                       │
└─────────────────────────────────────────────────────────────────┘
```

## Flujo de autenticación (Login)

```
1. User taps "INGRESAR" 
   └─> LoginPage
       └─> AuthController.login(email, password)
           └─> LoginUseCase.call(email, password)
               └─> AuthRepository.login(email, password)
                   └─> AuthRemoteDataSource.login(email, password)
                       └─> DioClient.post('/auth/login/')
                           │
                           ├─ Success (200)
                           │  └─> { access, refresh, user{...} }
                           │      └─> SecureStorage.saveAccessToken()
                           │      └─> SecureStorage.saveRefreshToken()
                           │      └─> return User entity
                           │          └─> AuthController.state = Authenticated
                           │              └─> Navigate to /home
                           │
                           └─ Error (4xx/5xx)
                              └─> map to Failure
                                  └─> AuthController.state = Error
                                      └─> Show SnackBar
```

## Flujo de refresh automático

```
Request con access token expirado
  └─> AuthInterceptor.onError(401)
      └─> Lock requests
      └─> GET refreshToken from SecureStorage
      └─> POST /auth/refresh/ { refresh }
          │
          ├─ Success (200)
          │  └─> { access }
          │      └─> Save new access token
          │      └─> Retry original request with new token
          │      └─> Unlock requests
          │
          └─ Error (401 en refresh)
             └─> deleteTokens()
             └─> Navigate to /login
             └─> Unlock requests
```

## Dependencias de capas

```
Presentation  →  Application  →  Domain  ←  Infrastructure
     ↓               ↓                            ↓
   Core (network, storage, errors, routes)
```

**Regla**: Las capas internas NO conocen las externas
- ✅ Application → Domain
- ✅ Infrastructure → Domain
- ❌ Domain → Application
- ❌ Domain → Infrastructure

## State Management (Riverpod)

```dart
// Providers
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(...);
final dioClientProvider = Provider((ref) => DioClient());
final secureStorageProvider = Provider((ref) => SecureStorage());

// UI
Consumer(
  builder: (context, ref, child) {
    final authState = ref.watch(authControllerProvider);
    return authState.when(
      initial: () => SplashPage(),
      authenticated: (user) => HomePage(user),
      unauthenticated: () => LoginPage(),
      loading: () => CircularProgressIndicator(),
      error: (msg) => ErrorWidget(msg),
    );
  },
)
```

## Seguridad

- ✅ Tokens en `flutter_secure_storage` (AES-256)
- ✅ No logs de tokens en producción
- ✅ HTTPS obligatorio en prod
- ✅ Refresh automático antes de expiración
- ✅ Logout limpia todos los tokens
- ✅ Interceptor maneja 401/403 globalmente

---

**Versión**: Fase 0 completada  
**Próximo**: Implementar Domain + Application + Infrastructure
