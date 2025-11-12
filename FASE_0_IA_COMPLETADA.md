# FASE 0 — Preparación mínima (Dio + rutas + permisos) ✅

## Objetivo
Dejar lista la base para consumir `/api/ai/*` endpoints con timeout extendido y autenticación JWT.

## ✅ Tareas Completadas

### 1. Verificación de Dio Global
- ✅ **DioClient configurado** en `lib/core/network/dio_client.dart`
  - Timeout base: 30s (para requests normales)
  - Headers: `Content-Type: application/json`, `Accept: application/json`
  - LogInterceptor activado para debug

### 2. AuthInterceptor JWT
- ✅ **AuthInterceptor funcionando** en `lib/core/network/auth_interceptor.dart`
  - Inyecta `Authorization: Bearer <token>` automáticamente
  - Excluye rutas de autenticación (`/auth/login/`, `/auth/register/`, `/auth/refresh/`)
  - Maneja refresh automático en caso de 401
  - Previene múltiples refreshes simultáneos

### 3. Provider de Dio para IA
- ✅ **aiDioProvider creado** en `lib/core/providers/app_providers.dart`
  - Timeout extendido: **120 segundos** (connect/receive/send)
  - Copia todos los interceptores del DioClient base (incluyendo AuthInterceptor)
  - Reutiliza baseUrl del environment (`Env.apiBaseUrl`)
  - Similar al `reportsDioProvider` que ya funcionaba correctamente

### 4. Archivo de Endpoints
- ✅ **AIEndpoints creado** en `lib/features/ai/ai_endpoints.dart`
  ```dart
  class AIEndpoints {
    static const String aiDashboard = '/ai/dashboard/';
    static const String aiForecast = '/ai/predictions/sales-forecast/';
    static const String aiTrain = '/ai/train-model/';
    static const String aiActiveModel = '/ai/active-model/';
    static const String aiListModels = '/ai/models/';
    static const String aiPredictionsHistory = '/ai/predictions/history/';
  }
  ```

## 🎯 Criterios de Aceptación (CUMPLIDOS)

✅ **El Dio global queda utilizable por el módulo IA**
- Provider `aiDioProvider` disponible en toda la app
- Configuración de timeouts adecuada para operaciones largas (120s)

✅ **Respeta JWT automáticamente**
- AuthInterceptor copia correctamente al aiDio
- Header `Authorization: Bearer <token>` se inyecta en todos los requests
- Refresh automático funciona en caso de token expirado

## 📁 Estructura Creada

```
lib/
├── core/
│   ├── network/
│   │   ├── dio_client.dart          ✅ (existente, verificado)
│   │   └── auth_interceptor.dart    ✅ (existente, verificado)
│   └── providers/
│       └── app_providers.dart       ✅ (actualizado con aiDioProvider)
└── features/
    └── ai/
        └── ai_endpoints.dart        ✅ (nuevo)
```

## 🔄 Uso Ejemplo

```dart
// En cualquier parte de la app
final aiDio = ref.read(aiDioProvider);

// Hacer request a IA (JWT se inyecta automáticamente)
final response = await aiDio.get(AIEndpoints.aiDashboard);

// Para POST con timeout largo
final forecast = await aiDio.post(
  AIEndpoints.aiForecast,
  data: {'months': 6, 'product_id': '123'},
);
```

## ✅ Estado: FASE 0 COMPLETADA

La base está lista para implementar las siguientes fases:
- FASE 1: Dashboard de IA
- FASE 2: Predicciones de Ventas
- FASE 3: Entrenamiento de Modelos
