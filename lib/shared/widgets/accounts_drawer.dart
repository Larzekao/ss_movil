import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_movil/shared/widgets/can.dart';

/// Drawer reutilizable para las páginas de gestión de cuentas
class AccountsDrawer extends StatefulWidget {
  final dynamic user;
  final String? currentRoute;

  const AccountsDrawer({super.key, required this.user, this.currentRoute});

  @override
  State<AccountsDrawer> createState() => _AccountsDrawerState();
}

class _AccountsDrawerState extends State<AccountsDrawer> {
  bool _accountsExpanded = false;
  bool _productsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header del drawer
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            accountName: Text(
              '${widget.user.nombre} ${widget.user.apellido ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(widget.user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.user.nombre[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),

          // Dashboard / Home
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            selected: widget.currentRoute == '/home',
            onTap: () {
              Navigator.pop(context);
              context.go('/home');
            },
          ),

          const Divider(),

          // Paquete: Gestión de Cuentas
          ExpansionTile(
            leading: const Icon(Icons.security, color: Colors.purple),
            title: const Text('Gestión de Cuentas'),
            initiallyExpanded: _accountsExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _accountsExpanded = expanded;
              });
            },
            children: [
              // Usuarios
              ListTile(
                contentPadding: const EdgeInsets.only(left: 72, right: 16),
                leading: const Icon(Icons.people, color: Colors.indigo),
                title: const Text('Usuarios'),
                selected:
                    widget.currentRoute?.startsWith('/accounts/users') ?? false,
                onTap: () {
                  Navigator.pop(context);
                  context.go('/accounts/users');
                },
              ),

              // Roles
              ListTile(
                contentPadding: const EdgeInsets.only(left: 72, right: 16),
                leading: const Icon(Icons.badge, color: Colors.deepPurple),
                title: const Text('Roles'),
                selected:
                    widget.currentRoute?.startsWith('/accounts/roles') ?? false,
                onTap: () {
                  Navigator.pop(context);
                  context.go('/accounts/roles');
                },
              ),

              // Permisos
              ListTile(
                contentPadding: const EdgeInsets.only(left: 72, right: 16),
                leading: const Icon(Icons.security, color: Colors.teal),
                title: const Text('Permisos'),
                selected: widget.currentRoute == '/accounts/permissions',
                onTap: () {
                  Navigator.pop(context);
                  context.go('/accounts/permissions');
                },
              ),
            ],
          ),

          const Divider(),

          // Paquete: Gestión de Productos
          ExpansionTile(
            leading: const Icon(Icons.inventory_2, color: Colors.deepOrange),
            title: const Text('Gestión de Productos'),
            initiallyExpanded: _productsExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _productsExpanded = expanded;
              });
            },
            children: [
              // Productos
              ListTile(
                contentPadding: const EdgeInsets.only(left: 72, right: 16),
                leading: const Icon(Icons.checkroom, color: Colors.purple),
                title: const Text('Productos'),
                selected: widget.currentRoute?.startsWith('/products') ?? false,
                onTap: () {
                  Navigator.pop(context);
                  context.go('/products');
                },
              ),

              // Categorías
              ListTile(
                contentPadding: const EdgeInsets.only(left: 72, right: 16),
                leading: const Icon(Icons.category, color: Colors.teal),
                title: const Text('Categorías'),
                selected:
                    widget.currentRoute?.startsWith('/categories') ?? false,
                onTap: () {
                  Navigator.pop(context);
                  context.go('/categories');
                },
              ),

              // Marcas
              ListTile(
                contentPadding: const EdgeInsets.only(left: 72, right: 16),
                leading: const Icon(
                  Icons.branding_watermark,
                  color: Colors.purple,
                ),
                title: const Text('Marcas'),
                selected: widget.currentRoute?.startsWith('/brands') ?? false,
                onTap: () {
                  Navigator.pop(context);
                  context.go('/brands');
                },
              ),
            ],
          ),

          const Divider(),

          // Órdenes
          ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.teal),
            title: const Text('Órdenes'),
            selected: widget.currentRoute?.startsWith('/admin/orders') ?? false,
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/orders');
            },
          ),
          // Reportes
          // Solo mostrar si el usuario tiene permiso para ver/generar reportes
          // Utiliza el helper `CanMultiple` para comprobar 'reportes.ver' OR 'reportes.generar'
          // (El widget `CanMultiple` está en lib/shared/widgets/can.dart)
          CanMultiple(
            permissionCodes: ['reportes.ver', 'reportes.generar'],
            requireAll: false,
            child: ListTile(
              leading: const Icon(Icons.insert_chart, color: Colors.blueGrey),
              title: const Text('Reportes'),
              selected:
                  widget.currentRoute?.startsWith('/admin/reports') ?? false,
              onTap: () {
                Navigator.pop(context);
                context.go('/admin/reports');
              },
            ),
          ),

          // IA - Predicciones
          ListTile(
            leading: const Icon(Icons.psychology, color: Colors.purple),
            title: const Text('IA - Predicciones'),
            selected: widget.currentRoute?.startsWith('/admin/ai') ?? false,
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/ai');
            },
          ),
        ],
      ),
    );
  }
}
