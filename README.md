# SS Movil

Aplicación móvil Android desarrollada con **Flutter** e integrada con el backend Django de SS Backend.

## 🏗️ Arquitectura

- **Clean Architecture** (Domain → Application → Infrastructure → Presentation)
- **Estado**: Riverpod
- **Networking**: Dio con interceptores JWT
- **Navegación**: go_router
- **Storage seguro**: flutter_secure_storage
- **Generación de código**: freezed + json_serializable

## 🚀 Configuración

### 1. Instalar dependencias

```bash
flutter pub get
```

### 2. Generar código freezed

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Configurar entorno

Edita `.env.dev` con la URL de tu backend local:

```env
API_BASE_URL=http://10.0.2.2:8000/api
```

> **Nota**: `10.0.2.2` es la IP del host desde el emulador Android

### 4. Ejecutar

```bash
flutter run
```

## 📁 Estructura del proyecto

```
lib/
├── core/
│   ├── env/               # Variables de entorno
│   ├── network/           # Cliente Dio
│   ├── errors/            # Failures tipados
│   ├── storage/           # Secure storage
│   └── routes/            # Navegación
└── features/
    └── accounts/
        ├── domain/        # Entidades y repositorios
        ├── application/   # Casos de uso y estado
        ├── infrastructure/# Implementaciones
        └── presentation/  # UI (pages, widgets)
```

## 🔐 Autenticación

Sistema JWT con:
- Access token (60 min)
- Refresh token (1 día)
- Refresh automático con interceptor
- Almacenamiento seguro de tokens

## 📝 Endpoints backend

- `POST /api/auth/login/` - Login
- `POST /api/auth/register/register/` - Registro
- `POST /api/auth/refresh/` - Refresh token
- `GET /api/auth/users/me/` - Usuario actual

## 🧪 Estado actual (Fase 0)

✅ Proyecto Flutter creado  
✅ Dependencias configuradas  
✅ Variables de entorno (.env.dev, .env.prod)  
✅ Cliente Dio con logging  
✅ Failures tipados con freezed  
✅ Secure storage para tokens  
✅ Navegación funcional (Splash → Login → Home)  
✅ Páginas mock operativas  

**Siguiente fase**: Implementar autenticación real con el backend.
