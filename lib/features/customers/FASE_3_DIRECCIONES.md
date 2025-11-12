# Fase 3 — Direcciones (CRUD + Principal)

## Descripción

Implementación completa de gestión de direcciones con CRUD y selección de dirección principal con actualización optimista.

## Archivos Creados

### Presentation Layer

#### `presentation/controllers/addresses_state.dart`
- **AddressesState**: Estado inmutable con:
  - `items`: Lista de Direccion
  - `loading`: Boolean para indicar carga
  - `error`: String opcional con mensaje de error
  - Getter `principal`: Retorna la dirección marcada como principal
- Incluye `copyWith()` para immutabilidad

#### `presentation/controllers/addresses_controller.dart`
- **AddressesController**: StateNotifier que gestiona:
  - `load()`: Carga lista de direcciones desde `/customers/direcciones/`
  - `create(etiqueta, direccionCompleta)`: POST a `/customers/direcciones/`
    - Primera dirección es automáticamente principal
  - `update(id, etiqueta, direccionCompleta)`: PATCH a `/customers/direcciones/{id}/`
  - `delete(id)`: DELETE a `/customers/direcciones/{id}/`
  - `setPrincipal(id)`: POST a `/customers/direcciones/{id}/set-principal/`
    - Implementa **optimistic update**: actualiza UI antes de confirmar
    - Si falla backend: revierte cambios y carga lista de nuevo
  - `clear()`: Limpia el estado

- Proveedores Riverpod:
  - `listAddressesUseCaseProvider`: Use case para listar
  - `createAddressUseCaseProvider`: Use case para crear
  - `setPrincipalAddressUseCaseProvider`: Use case para principal
  - `customersRepositoryProvider`: Repositorio reutilizable
  - `addressesControllerProvider`: Acceso principal al controlador

#### `presentation/pages/addresses_page.dart`
- **AddressesPage**: ConsumerStatefulWidget que:
  - Carga automáticamente direcciones al abrir (`initState`)
  - Muestra lista vacía con CTA si no hay direcciones
  - Radio buttons para seleccionar principal (cada radio dispara `setPrincipal`)
  - Badge "Principal" en dirección seleccionada
  - FAB "Agregar dirección" abre modal
  - Por cada item: botones "Editar" y "Eliminar"
  - Modal para crear/editar:
    - Campos: Etiqueta, Dirección Completa
    - Validación básica (no vacíos)
    - Diferencia entre crear y editar por título

### Application Layer

#### `application/usecases/update_address_usecase.dart`
- Caso de uso para actualizar dirección

#### `application/usecases/delete_address_usecase.dart`
- Caso de uso para eliminar dirección

## Flujos UX

### Crear Dirección
1. Usuario presiona FAB
2. Se abre modal con campos vacíos
3. Completa etiqueta y dirección
4. Presiona "Agregar"
5. POST al backend
6. Se añade a la lista
7. Si es la primera: se marca como principal automáticamente

### Editar Dirección
1. Usuario presiona "Editar" en tarjeta
2. Se abre modal con datos precargados
3. Modifica campos
4. Presiona "Guardar Cambios"
5. PATCH al backend
6. Se actualiza en la lista

### Eliminar Dirección
1. Usuario presiona "Eliminar" en tarjeta
2. Aparece diálogo de confirmación
3. Si confirma: DELETE al backend
4. Se elimina de la lista

### Cambiar Principal (Optimistic Update)
1. Usuario selecciona radio de otra dirección
2. **Inmediatamente** en UI:
   - La dirección anterior pierde "Principal"
   - La nueva dirección gana "Principal"
3. Backend: POST `/customers/direcciones/{id}/set-principal/`
4. Si backend responde OK: todo bien
5. Si backend falla:
   - Se revierte UI (carga lista de nuevo)
   - Se muestra error al usuario

## Criterios de Aceptación

✅ **CRUD Funciona**
- Crear nueva dirección: POST exitoso
- Leer lista: GET exitoso
- Actualizar: PATCH exitoso
- Eliminar: DELETE exitoso

✅ **Principal Funciona**
- Cambiar principal actualiza UI al instante (optimistic)
- Backend confirma cambio
- Si falla: revertir automático

✅ **Primera Dirección**
- La primera dirección creada es automáticamente principal
- `es_principal: true`

✅ **Validación**
- No permite crear/editar con campos vacíos
- Muestra SnackBar si hay error

✅ **Estados de Carga**
- Loading spinner mientras carga
- Error card si falla
- Empty state si no hay direcciones

## Testing Manual

```dart
// Flujo completo:
1. Navegar a /addresses
2. Ver "No tienes direcciones registradas"
3. Click FAB → Modal abierto
4. Completar "Casa", "Calle 123, Ciudad"
5. Click Agregar → Dirección aparece con badge "Principal"
6. Click FAB nuevamente → Agregar "Oficina", "Calle 456"
7. Radio de "Oficina" → UI cambia inmediatamente, "Oficina" es principal
8. Click Editar en "Casa" → Modal con datos precargados
9. Cambiar nombre a "Casa Nueva"
10. Click Guardar → Actualiza en lista
11. Click Eliminar en "Casa Nueva" → Confirmación
12. Click Eliminar → Desaparece de lista
13. "Oficina" sigue siendo principal
```

## Integración con App

Rutas esperadas en GoRouter:
```dart
/addresses → AddressesPage
```

Desde ProfilePage o drawer se puede navegar a:
```dart
context.push('/addresses');
```

## Próximos Pasos

- Integrar direcciones en checkout
- Mostrar dirección principal en perfil
- Geolocalización para autocompletar
- Búsqueda/validación de direcciones con Google Maps
