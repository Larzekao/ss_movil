import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

          // Panel de Administración
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: Colors.blue),
            title: const Text('Panel de Admin'),
            selected: widget.currentRoute == '/admin',
            onTap: () {
              Navigator.pop(context);
              context.go('/admin');
            },
          ),
        ],
      ),
    );
  }
}
