import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/cart_service.dart';
import '../login_screen.dart';
import 'admin_accounts_screen.dart';
import 'admin_overview_screen.dart';
import 'admin_products_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  static const _titles = ['Overview', 'Products', 'Accounts'];
  static const _icons = [
    Icons.dashboard_outlined,
    Icons.inventory_2_outlined,
    Icons.people_outline,
  ];

  final _pages = const [
    AdminOverviewScreen(),
    AdminProductsScreen(),
    AdminAccountsScreen(),
  ];

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Log out')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    AuthService().logout();
    CartService().clearLocal();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Safety net: only admins ever see this screen.
    if (!AuthService().isAdmin) {
      return const Scaffold(body: Center(child: Text('Admins only')));
    }

    final wide = MediaQuery.of(context).size.width >= 800;
    final body = IndexedStack(index: _index, children: _pages);

    final appBar = AppBar(
      title: Text('Admin Dashboard · ${_titles[_index]}'),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(AuthService().currentUsername ?? ''),
          ),
        ),
        IconButton(
          tooltip: 'Log out',
          icon: const Icon(Icons.logout),
          onPressed: _logout,
        ),
      ],
    );

    if (wide) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (var i = 0; i < _titles.length; i++)
                  NavigationRailDestination(
                      icon: Icon(_icons[i]), label: Text(_titles[i])),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (var i = 0; i < _titles.length; i++)
            NavigationDestination(icon: Icon(_icons[i]), label: _titles[i]),
        ],
      ),
    );
  }
}