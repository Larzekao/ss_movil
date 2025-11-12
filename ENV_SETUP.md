# Configuración de Entornos - SS Movil

## Variables de Entorno

La app móvil se conecta al backend usando variables de entorno definidas en archivos `.env`.

### Archivos de Configuración

- `.env.dev` - Configuración para desarrollo (localhost)
- `.env.prod` - Configuración para producción (AWS)

### Entorno Desarrollo (.env.dev)
```
API_BASE_URL=http://10.0.2.2:8000/api
```
- URL: `http://10.0.2.2:8000/api` (emulador Android - acceso a localhost)
- Puerto: 8000
- Backend local

### Entorno Producción (.env.prod)
```
API_BASE_URL=http://52.0.69.138:8000/api
```
- URL: `http://52.0.69.138:8000/api` (EC2 AWS)
- Puerto: 8000
- Backend en AWS

## Cómo Ejecutar la App

### Desarrollo (Default)
```bash
flutter run
```
- Usa `.env.dev` automáticamente
- Se conecta a `http://10.0.2.2:8000/api`

### Producción (AWS)
Editar `lib/main.dart` y cambiar:
```dart
// De:
await Env.load(env: 'dev');

// A:
await Env.load(env: 'prod');
```

O compilar con argumento:
```bash
flutter run --dart-define=ENVIRONMENT=production
```

## Configuración del Backend en AWS

```
IP: 52.0.69.138
Puerto: 8000
Base URL API: http://52.0.69.138:8000/api

Database:
- Host: 172.31.0.117
- Puerto: 5432
- Base de datos: smartsales_db
```

## Endpoints Disponibles

Todos los endpoints van prefijados con `/api`:

- `/auth/users/me/` - Obtener perfil actual
- `/customers/direcciones/` - Gestionar direcciones
- `/customers/preferencias/` - Gestionar preferencias
- `/customers/favoritos/` - Gestionar favoritos
- `/auth/refresh/` - Refrescar token JWT

## Manejo de Tokens

Los tokens JWT se guardan de forma segura en `FlutterSecureStorage`:
- `access_token` - Token de acceso (60 minutos)
- `refresh_token` - Token de refresco (1 día)

El interceptor de Dio:
1. Agrega el token a cada solicitud
2. Si recibe 401, intenta refrescar automáticamente
3. Si falla, borra tokens y redirige a login

## CORS

El backend permite CORS desde:
- `http://52.0.69.138`
- `http://52.0.69.138:5173` (frontend Vue)

## Próximos Pasos

- [ ] Configurar HTTPS en la app
- [ ] Validar certificados SSL en producción
- [ ] Agregar manejo de errores mejorado
- [ ] Agregar logs centralizados
