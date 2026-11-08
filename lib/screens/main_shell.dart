import 'dart:async';
import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/notifications_service.dart';
import '../utils/responsive.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import '../widgets/app_bottom_bar.dart';
import 'settings_screen.dart';
import '../services/voucher_service.dart';
import '../widgets/voucher_popup.dart';


class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final ValueNotifier<int> _unread = ValueNotifier(0);
  StreamSubscription<List<AppNotification>>? _sub;

  final _pages = const [
    HomeScreen(),
    CartScreen(),
    NotificationsScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _sub = NotificationService.stream().listen((list) {
      _unread.value = list.where((n) => n.unread).length;
    }, onError: (_) {});
          WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted || !VoucherService.promptPending) return;
    VoucherService.promptPending = false;
    showVoucherPopup(context);
  });
    
  }

  @override
  void dispose() {
    _sub?.cancel();
    _unread.dispose();
    super.dispose();
  }

  Widget _cartIcon() => ListenableBuilder(
        listenable: CartService(),
        builder: (_, _) => Badge(
          isLabelVisible: CartService().totalCount > 0,
          label: Text('${CartService().totalCount}'),
          child: const Icon(Icons.shopping_cart),
        ),
      );

  Widget _notifIcon() => ValueListenableBuilder<int>(
        valueListenable: _unread,
        builder: (_, count, _) => Badge(
          isLabelVisible: count > 0,
          label: Text('$count'),
          child: const Icon(Icons.notifications),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= Responsive.railBreakpoint;
    final body = IndexedStack(index: _index, children: _pages);

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              destinations: [
                const NavigationRailDestination(
                    icon: Icon(Icons.home), label: Text('Home')),
                NavigationRailDestination(
                    icon: _cartIcon(), label: const Text('Cart')),
                NavigationRailDestination(
                    icon: _notifIcon(), label: const Text('Notification')),
                const NavigationRailDestination(
                    icon: Icon(Icons.person), label: Text('Profile')),
                const NavigationRailDestination(
                    icon: Icon(Icons.settings), label: Text('Settings')),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

            return Scaffold(
              body: body,
            bottomNavigationBar: AppBottomBar(
          index: _index,
          onTap: (i) => setState(() => _index = i),
          icons: [
            const Icon(Icons.home_outlined),
            _cartIcon(),
            _notifIcon(),
            const Icon(Icons.person_outline),
            const Icon(Icons.settings_outlined),
          ],
        ),
    );
  }
}