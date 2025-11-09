# Registro de Fases - SS Movil

---

## Fase 0 — Base del Proyecto ✅

**Fecha**: 8 Nov 2025  
**Estado**: Completado

### 1. Proyecto Flutter creado
- **Ubicación**: `segundo_parcial/ss_movil/`
- **Package**: `com.example.ss_movil`
- **Plataforma**: Android (compatible con todas)

### 2. Dependencias instaladas

```yaml
dependencies:
  dio: ^5.4.0                      # HTTP client
  flutter_riverpod: ^2.5.1        # State management
  go_router: ^13.0.0               # Navegación
  flutter_secure_storage: ^9.0.0  # Storage seguro
  freezed_annotation: ^2.4.1      # Inmutabilidad
  json_annotation: ^4.8.1         # JSON

dev_dependencies:
  build_runner: ^2.4.8
  freezed: ^2.4.7
  json_serializable: ^6.7.1
```

### 3. Configuración de entorno

**Archivos creados:**
- `.env.dev` → `API_BASE_URL=http://10.0.2.2:8000/api`
- `.env.prod` → `API_BASE_URL=https://api.produccion.com/api`

**Clase Env** (`lib/core/env/env.dart`):
```dart
await Env.load(env: 'dev');
String url = Env.apiBaseUrl;
```

### 4. Core implementado

#### `lib/core/network/dio_client.dart`
- Cliente Dio centralizado
- BaseURL desde `Env.apiBaseUrl`
- Timeouts: 30s (connect, receive, send)
- Logging de requests/responses en debug
- Headers por defecto: `Content-Type: application/json`

#### `lib/core/errors/failures.dart`
- Failures tipados con **freezed**:
  - `NetworkFailure` (timeout, no internet)
  - `AuthFailure` (401, 403)
  - `ServerFailure` (500+)
  - `ValidationFailure` (400)
  - `UnknownFailure`

#### `lib/core/storage/secure_storage.dart`
- Wrapper de `flutter_secure_storage`
- Métodos:
  - `saveAccessToken()`
  - `saveRefreshToken()`
  - `getAccessToken()`
  - `getRefreshToken()`
  - `deleteTokens()`
  - `hasTokens()`

### 5. Navegación con go_router

**Rutas implementadas:**
- `/splash` → `SplashPage` (inicial, 2s delay)
- `/login` → `LoginPage`
- `/register` → `RegisterPage`
- `/home` → `HomePage`

**Flujo actual (mock):**
```
Splash (2s) → Login → Home
              ↓
           Register → Login
```

### 6. Páginas mock

Todas funcionales con UI básica Material Design:
- ✅ `SplashPage`: Logo + spinner, redirige a Login
- ✅ `LoginPage`: Campos email/password, botón mock
- ✅ `RegisterPage`: Formulario completo de registro
- ✅ `HomePage`: Pantalla de bienvenida con logout

### 7. Build runner ejecutado

```bash
dart run build_runner build --delete-conflicting-outputs
```
- Generado: `lib/core/errors/failures.freezed.dart`

## 📁 Estructura final

```
ss_movil/
├── .env.dev
├── .env.prod
├── pubspec.yaml
├── README.md
├── lib/
│   ├── main.dart                    # Entry point con Env.load()
│   ├── core/
│   │   ├── env/env.dart             # Variables de entorno
│   │   ├── network/dio_client.dart  # Cliente HTTP
│   │   ├── errors/failures.dart     # Errors tipados
│   │   ├── storage/secure_storage.dart
│   │   └── routes/app_router.dart   # GoRouter config
│   └── features/accounts/
│       └── presentation/pages/
│           ├── splash_page.dart
│           ├── login_page.dart
│           ├── register_page.dart
│           └── home_page.dart
└── android/
```

## 🧪 Criterios de aceptación

| Criterio | Estado |
|----------|--------|
| Compila en Android | ✅ Sin errores |
| API_BASE_URL inyectado desde env | ✅ `Env.apiBaseUrl` |
| Navegación Splash → Login → Home | ✅ Funcional con mock |
| Dependencias instaladas | ✅ `flutter pub get` OK |
| Freezed generado | ✅ `build_runner` OK |

## 🎯 Próximos pasos (Fase 1)

1. **Domain Layer**:
   - Entidades: `User`, `Role`, `Permission`
   - Repository interface: `AuthRepository`
   
2. **Application Layer**:
   - UseCases: `LoginUseCase`, `RegisterUseCase`, `LogoutUseCase`
   - State: `AuthController` con Riverpod

3. **Infrastructure Layer**:
   - DTOs con `json_serializable`
   - `AuthRemoteDataSource` con Dio
   - `AuthRepositoryImpl`

4. **Auth Interceptor**:
   - Inyectar `Authorization: Bearer {access}`
   - Refresh automático en 401
   - Reintento 1 vez

5. **Guards**:
   - `Can` widget por permiso
   - `ProtectedRoute` con verificación

## 📝 Comandos útiles

```bash
# Instalar dependencias
flutter pub get

# Generar código freezed/json
dart run build_runner build --delete-conflicting-outputs

# Ejecutar en emulador
flutter run

# Limpiar build
flutter clean

# Ver dispositivos
flutter devices
```

## 🔍 Notas técnicas

### IP del emulador Android
- `10.0.2.2` → localhost del host
- `localhost` NO funciona desde el emulador

### Cambiar entre dev/prod
Editar `lib/main.dart`:
```dart
await Env.load(env: 'dev');  // o 'prod'
```

### Hot reload
- `r` → Hot reload (mantiene estado)
- `R` → Hot restart (reinicia app)
- `q` → Quit

---

## Fase 1 — Autenticación (login/register/me/refresh) ✅

**Fecha**: 8 Nov 2025  
**Estado**: Completado

**Objetivo**: Flujo de auth funcional de punta a punta

### Implementado

**Domain Layer:**
- ✅ Entidades: `User`, `Role`, `Permission` (freezed)
- ✅ Repository: `AuthRepository` (abstracto)
- ✅ Métodos del usuario: `tienePermiso()`, `tieneRol()`

**Infrastructure Layer:**
- ✅ DTOs: `LoginResponseDto`, `UserDto`, `RoleDto`, `PermissionDto` (freezed + json_serializable)
- ✅ DataSource: `AuthRemoteDataSource` (login, register, me, refresh)
- ✅ Repository: `AuthRepositoryImpl` con mapeo DTO ↔ entidades
- ✅ Manejo de errores: `_handleDioError()` con Failures tipados

**Application Layer:**
- ✅ Estados: `AuthState` (initial, unauthenticated, authenticating, authenticated, error)
- ✅ Controller: `AuthController` (checkAuth, login, register, refreshUser, logout)

**Core:**
- ✅ `AuthInterceptor`: Inyecta Bearer token y refresh automático ante 401
- ✅ Providers Riverpod: `authControllerProvider`, `authRepositoryProvider`, etc.

**UI (Presentation):**
- ✅ `SplashPage`: Verifica tokens al iniciar → redirige a Login/Home
- ✅ `LoginPage`: Form validado, loader, manejo de errores
- ✅ `RegisterPage`: Form completo con validación y confirmación de password
- ✅ `HomePage`: Muestra datos del usuario autenticado con logout funcional

### Criterios de aceptación
- ✅ Login funcional → navega a Home
- ✅ Refresh transparente ante expiración (AuthInterceptor)
- ✅ Logout limpia tokens y redirige a Login
- ✅ SplashPage carga usuario si hay tokens válidos
- ✅ Errores mostrados con SnackBar
- ✅ Estados de loading en botones

### Endpoints integrados
- `POST /api/auth/login/` → Guarda access + refresh tokens
- `POST /api/auth/register/register/` → Crea usuario rol Cliente
- `POST /api/auth/refresh/` → Obtiene nuevo access token
- `GET /api/auth/users/me/` → Obtiene usuario actual autenticado

### Archivos generados
- **20 archivos .freezed.dart y .g.dart** con build_runner

---

**Última actualización**: Fase 1 completada ✅ (8 Nov 2025)
