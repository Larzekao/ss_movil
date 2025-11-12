# Fase 4 — Preferencias (Notificaciones, Idioma, Talla Favorita)

## Descripción

Implementación de pantalla de preferencias del usuario con auto-save con debounce, manejo de errores y mensajes de estado.

## Archivos Creados

### Presentation Layer

#### `presentation/controllers/preferences_state.dart`
- **PreferencesState**: Estado inmutable con:
  - `data`: Objeto Preferencias (notificaciones, idioma, tallaFavorita)
  - `loading`: Boolean para indicar carga
  - `error`: String opcional con mensaje de error
  - `successMessage`: String opcional con mensaje de éxito temporal
- Incluye `copyWith()` para immutabilidad

#### `presentation/controllers/preferences_controller.dart`
- **PreferencesController**: StateNotifier que gestiona:
  - `load()`: Carga preferencias desde `GET /customers/preferences/`
  - `updateWithDebounce(...)`: Actualiza UI inmediatamente, debounce 400ms para backend
    - Cancela timer anterior si existe
    - Muestra cambios optimistas en UI
    - Solo envía al backend después de 400ms sin cambios
  - `updateNow(...)`: Actualiza sin debounce (para actualizaciones inmediatas)
  - `_performUpdate(...)`: Ejecuta actualización PATCH
    - Muestra mensaje "Preferencias guardadas" por 2 segundos
    - Maneja excepciones y muestra errores
  - `clear()`: Limpia el estado y cancela timers
  - `dispose()`: Limpieza en destrucción

- **Debounce Logic**:
  ```
  Usuario cambia control
    ↓
  updateWithDebounce() → UI actualiza inmediatamente
    ↓
  Timer de 400ms inicia
    ↓
  Si usuario hace otro cambio → Timer cancelado, reinicia
    ↓
  Si 400ms pasan sin cambios → _performUpdate() entra en backend
  ```

- Proveedores Riverpod:
  - `getPreferencesUseCaseProvider`: Use case para obtener
  - `updatePreferencesUseCaseProvider`: Use case para actualizar
  - `customersRepositoryProvider`: Repositorio reutilizable
  - `preferencesControllerProvider`: Acceso principal

#### `presentation/pages/preferences_page.dart`
- **PreferencesPage**: ConsumerStatefulWidget que:
  - Carga preferencias al abrir (`initState`)
  - Limpia timers al cerrar (`dispose`)
  - Muestra loading spinner mientras carga
  - Muestra error card si falla la carga inicial
  - 3 Secciones de controles:

    **1. Notificaciones**
    - Switch "Recibir notificaciones"
    - Descripción: "Notificaciones push sobre pedidos"
    - Dispara `updateWithDebounce(notificaciones: value)`

    **2. Idioma**
    - DropdownButton con opciones: es, en, pt
    - Valores: Español, English, Português
    - Dispara `updateWithDebounce(idioma: value)`

    **3. Talla Favorita**
    - DropdownButton con opciones: null, XS, S, M, L, XL, XXL
    - Etiquetas descriptivas: "Extra Pequeño (XS)", etc.
    - Dispara `updateWithDebounce(tallaFavorita: value)`

  - **Feedback Visual**:
    - Mensaje verde "Preferencias guardadas" aparece 2s después de guardar
    - Mensaje rojo con error si falla la actualización
    - Info box azul: "Los cambios se guardan automáticamente después de 400ms"

## Endpoints Esperados

```
GET /customers/preferences/
Respuesta: {
  "notificaciones": true,
  "idioma": "es",
  "talla_favorita": "M"
}

PATCH /customers/preferences/
Body: {
  "notificaciones": true,
  "idioma": "es",
  "talla_favorita": "M"
}
Respuesta: idem GET
```

## Flujo de Auto-Save

1. **Usuario cambia Switch de notificaciones a OFF**
2. `updateWithDebounce(notificaciones: false)` se ejecuta
3. **UI actualiza inmediatamente**: Switch está OFF, `successMessage` se limpia
4. Timer de 400ms inicia en background
5. **Escenarios**:
   - **A) Usuario no toca nada**: Después de 400ms, se envía PATCH al backend
     - Backend responde OK → `successMessage: "Preferencias guardadas"`
     - Mensaje desaparece después de 2s
   - **B) Usuario cambia idioma a "en"**: 
     - Timer anterior se cancela (no se envía notificaciones)
     - UI actualiza (Switch OFF, Idioma EN)
     - Nuevo timer de 400ms inicia
     - Después de 400ms: Se envía PATCH con AMBOS cambios al backend

## Manejo de Errores

1. **Error de red/timeout**: 
   - Muestra mensaje rojo
   - Mantiene UI con último estado válido
   - Usuario puede reintentar haciendo cambios

2. **Error 401 (Unauthorized)**:
   - Interceptor de Dio intenta refrescar token
   - Si falla: vacía sesión, redirige a login

3. **Error 400 (Validación)**:
   - Muestra mensaje de error específico
   - UI se mantiene en estado anterior

## Criterios de Aceptación

✅ **Load funciona**
- Al abrir la página, se cargan preferencias
- Controls se populan con valores del backend

✅ **Auto-save con debounce**
- Cambios son visibles inmediatamente en UI
- Backend se actualiza después de 400ms sin cambios
- Mensaje "Guardado" aparece brevemente

✅ **Reintentos**
- Si hay error de red, el mensaje persiste
- Usuario puede cambiar otro control para reintentar

✅ **UX**
- No hay spinner durante cambios normales
- UI es responsive
- Feedback visual claro

## Optimizaciones

1. **Debounce**: Evita spam de requests al cambiar múltiples valores rápidamente
2. **Optimistic Updates**: UI se actualiza sin esperar backend
3. **Message Cleanup**: Mensajes de éxito desaparecen automáticamente
4. **Timer Cleanup**: Se cancela correctamente en dispose/clear

## Testing Manual

```dart
1. Navegar a /preferences
2. Esperar a que cargue
3. Cambiar Switch de notificaciones → Ver cambio inmediato
4. Esperar 400ms → Ver mensaje "Guardado"
5. Cambiar idioma a "en" → UI actualiza
6. Cambiar talla a "L" → UI actualiza
7. Esperar 400ms → Mensaje "Guardado" (por todos los cambios)
8. Desconectar red (airplane mode)
9. Cambiar Switch → UI actualiza, pero después de 400ms muestra error
10. Cambiar otro control → Se reintenta, envía si red vuelve
11. Cerrar página → Verifica que no hay memory leaks (timers limpios)
```

## Próximos Pasos

- Agregar validaciones más complejas (ej: restricciones de idioma por región)
- Integrar cambios de idioma en toda la app (i18n)
- Persistencia local con Hive/SQLite además del backend
- Sincronización bidireccional con cambios locales
