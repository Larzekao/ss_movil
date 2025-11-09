# Estado de Fase 3 y Fase 4 - CRUDs de Cuentas

**Fecha**: Implementación completa de UI y navegación  
**Estado**: ✅ UI y rutas completas - Pendiente capa de aplicación

## 📋 Resumen

Se han implementado todas las páginas de UI y rutas para la gestión de Usuarios, Roles y Permisos según lo especificado en Fase 3 y Fase 4.

## ✅ Completado

### 1. Rutas Implementadas

Todas las rutas están protegidas con `ProtectedRoute` y verifican permisos RBAC:

```dart
// Usuarios
/accounts/users              → UsersListPage (usuarios.listar)
/accounts/users/new          → UserFormPage (usuarios.crear)
/accounts/users/:id          → UserDetailPage (usuarios.listar)
/accounts/users/:id/edit     → UserFormPage (usuarios.editar)

// Roles
/accounts/roles              → RolesListPage (roles.listar)
/accounts/roles/new          → RoleFormPage (roles.crear)
/accounts/roles/:id/edit     → RoleFormPage (roles.editar)

// Permisos
/accounts/permissions        → PermissionsListPage (permisos.listar)
```

### 2. Navegación desde Home

Se agregó la sección "Gestión de Cuentas" en `home_page.dart` con 3 botones protegidos:

```dart
Can(permissionCode: 'usuarios.listar')  → Usuarios (indigo)
Can(permissionCode: 'roles.listar')     → Roles (deepPurple)
Can(permissionCode: 'permisos.listar')  → Permisos (teal)
```

### 3. Páginas Implementadas

#### 👥 Usuarios (3 páginas)

**`users_list_page.dart`**
- ✅ Barra de búsqueda con TextEditingController
- ✅ Filtro de estado (Activo/Inactivo) con DropdownButtonFormField
- ✅ ListView con datos mock (10 usuarios)
- ✅ FloatingActionButton protegido con `Can('usuarios.crear')`
- ✅ Navegación a detalle al tap en cada item
- ⚠️ Warning: `_selectedRoleId` declarado pero no usado (reservado para filtro futuro)

**`user_form_page.dart`**
- ✅ Modo crear/editar según parámetro `userId`
- ✅ Formulario completo con validaciones:
  - Email (requerido, formato válido)
  - Contraseña (solo en creación, mínimo 8 caracteres)
  - Confirmar contraseña (debe coincidir)
  - Nombre y Apellido (requeridos)
  - Teléfono (opcional)
  - Rol (dropdown requerido con opciones mock)
  - Código de empleado (opcional)
- ✅ Toggle para mostrar/ocultar contraseñas
- ✅ Botones Cancelar y Guardar
- ✅ Loading state durante submit
- ✅ SnackBar de éxito/error
- 🔄 TODO: Integrar con provider

**`user_detail_page.dart`**
- ✅ Avatar y encabezado con nombre/email
- ✅ Card con información personal
- ✅ Card de acciones con 3 botones:
  - Editar (navega a /accounts/users/:id/edit)
  - Desactivar/Activar (con dialog de confirmación)
  - Eliminar (con dialog de confirmación, navega a lista tras eliminar)
- 🔄 TODO: Integrar con provider

#### 🎭 Roles (2 páginas)

**`roles_list_page.dart`**
- ✅ Barra de búsqueda
- ✅ Lista de roles con datos mock (3 roles)
- ✅ Chip "Sistema" para roles del sistema
- ✅ FloatingActionButton protegido con `Can('roles.crear')`
- ✅ Navegación a edición al tap
- 🔄 TODO: Integrar con provider

**`role_form_page.dart`**
- ✅ Modo crear/editar según parámetro `roleId`
- ✅ Banner de advertencia para roles de sistema
- ✅ Campos: nombre (requerido), descripción (opcional)
- ✅ Sección de permisos agrupados por módulo:
  - Usuarios (4 permisos)
  - Roles (4 permisos)
  - Productos (4 permisos)
- ✅ CheckboxListTile para cada permiso
- ✅ Validación: mínimo 1 permiso seleccionado
- ✅ Botones Cancelar y Guardar/Crear
- 🔄 TODO: Integrar con provider y cargar permisos dinámicamente

#### 🔐 Permisos (1 página)

**`permissions_list_page.dart`**
- ✅ Banner informativo: "solo lectura"
- ✅ Barra de búsqueda
- ✅ Lista agrupada por módulos usando ExpansionTile
- ✅ 6 módulos mock: Usuarios, Roles, Permisos, Productos, Clientes, Pedidos
- ✅ Cada permiso muestra: nombre, descripción, código
- ✅ Iconos personalizados por módulo
- ✅ Sin botones de crear/editar/eliminar
- 🔄 TODO: Integrar con provider

### 4. Integración con RBAC

Todas las páginas usan correctamente los widgets de RBAC:

```dart
Can(permissionCode: 'usuarios.crear', child: FloatingActionButton(...))
ProtectedRoute(requiredPermission: 'usuarios.listar', child: UsersListPage())
```

### 5. Arquitectura

Estructura de archivos:
```
lib/features/accounts/presentation/pages/
├── users/
│   ├── users_list_page.dart
│   ├── user_form_page.dart
│   └── user_detail_page.dart
├── roles/
│   ├── roles_list_page.dart
│   └── role_form_page.dart
└── permissions/
    └── permissions_list_page.dart
```

## 🔄 Pendiente (Capa de Aplicación)

### Use Cases a Crear

```
lib/features/accounts/application/use_cases/
├── users/
│   ├── list_users.dart
│   ├── get_user.dart
│   ├── create_user.dart
│   ├── update_user.dart
│   ├── toggle_active_user.dart
│   └── delete_user.dart
├── roles/
│   ├── list_roles.dart
│   ├── get_role.dart
│   ├── create_role.dart
│   ├── update_role.dart
│   └── delete_role.dart
└── permissions/
    └── list_permissions.dart
```

### Providers a Crear

```dart
// lib/features/accounts/application/providers/users_providers.dart
final listUsersProvider = FutureProvider.autoDispose...
final getUserProvider = FutureProvider.family...
final createUserProvider = Provider...
final updateUserProvider = Provider...
final deleteUserProvider = Provider...
final toggleActiveUserProvider = Provider...

// Similar para roles y permissions
```

### Repository Implementation

```
lib/features/accounts/infrastructure/repositories/
├── users_repository_impl.dart
├── roles_repository_impl.dart
└── permissions_repository_impl.dart
```

Cada implementación debe:
- Inyectar el datasource correspondiente
- Implementar la interfaz del dominio
- Manejar errores con `Either<Failure, T>` (dartz)
- Transformar DTOs a entidades de dominio

## 📝 Notas Técnicas

### Datos Mock Actuales

**Usuarios (10 items):**
- Email: usuario1@example.com ... usuario10@example.com
- Estados: Activo/Inactivo alternados
- Roles: Admin/Vendedor/Cliente

**Roles (3 items):**
- Admin (es_sistema: true)
- Vendedor (es_sistema: false)
- Cliente (es_sistema: false)

**Permisos (25+ items agrupados en 6 módulos):**
- Usuarios: listar, crear, editar, eliminar
- Roles: listar, crear, editar, eliminar
- Permisos: listar
- Productos: listar, crear, editar, eliminar
- Clientes: listar, crear, editar, eliminar
- Pedidos: listar, crear, editar, eliminar

### Validaciones Implementadas

**Formulario de Usuario:**
- Email: requerido, formato @
- Contraseña: mínimo 8 caracteres (solo en creación)
- Confirmar contraseña: debe coincidir
- Nombre/Apellido: requeridos
- Rol: requerido

**Formulario de Rol:**
- Nombre: requerido
- Permisos: mínimo 1 seleccionado

### Manejo de Errores

Todas las páginas tienen:
- Estado `_isLoading` durante operaciones async
- Try-catch con SnackBar para mostrar errores
- Confirmación con AlertDialog para acciones destructivas (eliminar, desactivar)

## 🚀 Próximos Pasos

1. **Ejecutar build_runner** para generar código de Freezed:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Crear use cases** siguiendo el patrón:
   ```dart
   class ListUsers {
     final UsersRepository repository;
     
     Future<Either<Failure, PagedUsers>> call({
       int page = 1,
       String? search,
       bool? isActive,
     }) async {
       return await repository.listUsers(...);
     }
   }
   ```

3. **Implementar repositories** conectando datasources con dominio

4. **Crear providers** usando Riverpod

5. **Integrar providers en páginas** reemplazando datos mock

6. **Probar flujo completo** con backend real:
   - Login → Home → Usuarios → Crear/Editar/Eliminar
   - Login → Home → Roles → Crear/Editar
   - Login → Home → Permisos → Ver lista

## ✨ Características Destacadas

- ✅ Navegación funcional entre todas las páginas
- ✅ Protección RBAC en todas las rutas y acciones
- ✅ UI consistente con Material Design
- ✅ Formularios con validación completa
- ✅ Estados de carga y mensajes de feedback
- ✅ Confirmaciones para acciones destructivas
- ✅ Búsqueda y filtros en listas
- ✅ Datos mock preparados para reemplazo con API
- ✅ TODO comments marcando puntos de integración

## 📊 Cobertura de Requisitos

| Requisito | Estado | Notas |
|-----------|--------|-------|
| Rutas /accounts/users/* | ✅ | 4 rutas completas |
| Rutas /accounts/roles/* | ✅ | 3 rutas completas |
| Rutas /accounts/permissions | ✅ | 1 ruta completa |
| Botones en Home protegidos | ✅ | 3 botones con Can() |
| Páginas mínimas funcionales | ✅ | 6 páginas completas |
| Integración con RBAC | ✅ | Can + ProtectedRoute |
| Formularios con validación | ✅ | 2 formularios completos |
| Manejo de estados | ✅ | Loading, error, success |
| Providers/Use Cases | 🔄 | Pendiente implementar |
| Conexión con API | 🔄 | Datasources listos, falta integración |

---

**Conclusión**: La UI y navegación están 100% completas y funcionales con datos mock. El siguiente paso es implementar la capa de aplicación (use cases, providers, repository implementations) para conectar con el backend real.
