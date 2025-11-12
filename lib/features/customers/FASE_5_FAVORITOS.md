# Fase 5 — Favoritos (Mark/Unmark + Listar)

## Descripción

Implementación de sistema de favoritos con marcar/desmarcar productos, listar favoritos, y botón reutilizable para integrar en detalles de producto.

## Archivos Creados

### Presentation Layer - Controllers

#### `presentation/controllers/favorites_state.dart`
- **FavoritesState**: Estado inmutable con:
  - `favoriteIds`: Lista de IDs de productos marcados como favorito
  - `loading`: Boolean para indicar carga
  - `error`: String opcional con mensaje de error
  - Getter `isFavorite(productId)`: Verifica si un producto es favorito
- Incluye `copyWith()` para immutabilidad

#### `presentation/controllers/favorites_controller.dart`
- **FavoritesController**: StateNotifier que gestiona:
  - `load()`: Carga lista de IDs desde `GET /customers/favoritos/`
  - `toggleFavorite(productId)`: Toggle favorito (optimistic update)
    - Si no era favorito → agregalo
    - Si era favorito → elimínalo
    - Actualiza UI inmediatamente
    - Confirma con backend
    - Si falla: revierte cambios y muestra error
  - `clear()`: Limpia el estado

- **Optimistic Update Logic**:
  ```
  toggleFavorite(productId)
    ↓
  Guardar estado anterior (wasFavorite)
    ↓
  Actualizar UI inmediatamente
    ↓
  POST /customers/favoritos/toggle/ → Backend
    ↓
  ✓ OK: UI correcta, estado sincronizado
  ✗ Error: Revertir UI, mostrar snackbar
  ```

- Proveedores Riverpod:
  - `listFavoritesUseCaseProvider`: Use case para listar
  - `toggleFavoriteUseCaseProvider`: Use case para toggle
  - `customersRepositoryProvider`: Repositorio reutilizable
  - `favoritesControllerProvider`: Acceso principal

### Presentation Layer - Pages

#### `presentation/pages/favorites_page.dart`
- **FavoritesPage**: ConsumerStatefulWidget que:
  - Carga favoritos al abrir (`initState`)
  - GridView 2 columnas de productos favoritos
  - Cada tarjeta muestra:
    - Imagen placeholder (con icono)
    - Nombre del producto ("Producto #ID")
    - Precio (\$99.99)
    - Botón corazón para eliminar de favoritos (rojo, relleno)
  - Estados:
    - Loading: Spinner si está cargando
    - Error: Card roja con opción reintentar
    - Vacío: Icono corazón vacío, CTA "Ver Productos"
  - Confirmación: SnackBar al eliminar

### Presentation Layer - Widgets

#### `presentation/widgets/favorite_button.dart`
- **FavoriteButton**: Widget reutilizable ConsumerWidget
  - Props:
    - `productId`: ID del producto (required)
    - `size`: Tamaño del icono (default 24)
    - `showLabel`: Mostrar texto además del icono (default false)
    - `onError`: Callback si falla (opcional)
  - Muestra:
    - Corazón **relleno rojo** si es favorito
    - Corazón **outline gris** si no es favorito
  - Al presionar:
    - Toggle favorito (optimistic)
    - SnackBar: "Agregado a favoritos" o "Eliminado de favoritos"
    - Si hay error: llama `onError` y muestra SnackBar rojo
  - Variantes:
    - Icon mode: Solo icono (default)
    - Label mode: Chip con icono + texto "Favorito" o "Agregar"

### Presentation Layer - Examples

#### `presentation/pages/product_detail_page_example.dart`
- **ProductDetailPageExample**: Scaffold de ejemplo mostrando:
  - Cómo integrar `FavoriteButton` en AppBar (actions)
  - Layout completo con imagen, nombre, precio, descripción
  - Rating placeholder
  - Botones "Agregar al Carrito" y "Ver todos los favoritos"
  - Comentarios sobre uso en router GoRouter

## Endpoints Esperados

```
GET /customers/favoritos/
Respuesta: [1, 5, 12, 23]  # IDs de productos

POST /customers/favoritos/toggle/
Body: {
  "productId": 5
}
Respuesta: 200 OK
# Si 5 era favorito → se elimina
# Si 5 no era favorito → se agrega
```

## Flujos UX

### Agregar a Favoritos (desde product_detail)
1. Usuario ve botón corazón vacío en AppBar
2. Presiona → Icono se llena de rojo inmediatamente
3. SnackBar: "Agregado a favoritos"
4. Backend confirma
5. Si falla: Icono vuelve a vacío, SnackBar rojo

### Ver Favoritos
1. Usuario navega a /favorites
2. GridView muestra todos los favoritos con imagen placeholder
3. Presiona corazón en tarjeta → Se elimina con animación
4. SnackBar: "Eliminado de favoritos"
5. Grid se refresca

### Filtrar Favoritos
- En futuro: filtro por categoría, precio, etc.

## Criterios de Aceptación

✅ **Favorito refleja inmediatamente**
- Click en corazón → UI actualiza de inmediato

✅ **Errores muestran snackbar y revierten**
- Si POST falla → Icono revierte
- SnackBar rojo con error

✅ **Listar funciona**
- GridView muestra todos los favoritos
- Al eliminar → desaparece de grid

✅ **Toggle funciona en ambos sentidos**
- Agregar favorito ✓
- Eliminar favorito ✓

✅ **Widget reutilizable**
- FavoriteButton funciona en cualquier página
- Props customizables

## Testing Manual

```dart
// En ProductDetailPage:
1. Abrir detalles de un producto
2. Ver corazón outline en AppBar
3. Click → Se llena de rojo
4. SnackBar: "Agregado a favoritos"
5. Click nuevamente → Se vacía
6. SnackBar: "Eliminado de favoritos"

// En FavoritesPage:
1. Navegar a /favorites
2. Ver grid con favoritos previos
3. Click corazón en cualquier producto → Se elimina
4. Grid se actualiza inmediatamente
5. SnackBar confirma eliminación

// Error handling:
1. Desconectar red
2. Click en corazón → Se llena (optimistic)
3. Backend falla → Se vacía (reverso)
4. SnackBar rojo con error
5. Reconectar → Reintentar clicking otro producto
```

## Integración con Otras Fases

- **Fase 2 (Perfil)**: Link a favoritos desde perfil
- **Fase 3 (Direcciones)**: N/A
- **Fase 4 (Preferencias)**: Preferencias sobre notificaciones de favoritos
- **Fase 6+ (Productos/Carrito)**: Integración con producto detail y checkout

## Próximos Pasos

- Integración real con API de productos
- Caché local de favoritos (Hive/SQLite)
- Sincronización bidireccional
- Notificaciones para favoritos en descuento
- Compartir favoritos (social sharing)
- Sincronización entre dispositivos
