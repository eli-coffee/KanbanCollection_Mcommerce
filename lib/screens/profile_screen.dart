import 'package:flutter/material.dart';
import '../models/app_order.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../utils/responsive.dart';
import '../utils/strings.dart';
import '../widgets/user_avatar.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'manage_products_screen.dart';
import 'user_orders_screen.dart';
import '../services/settings_service.dart';
import 'vouchers_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Stream<List<AppOrder>> _stream =
      OrderService.streamForCurrentUser();

  
  
  static const _statusShortcuts = [
    ('Pre-order', Icons.schedule, 1),
    ('Processing', Icons.inventory_2_outlined, 2),
    ('Shipping', Icons.local_shipping_outlined, 3),
    ('Received', Icons.check_circle_outline, 4),
    ('Cancelled', Icons.cancel_outlined, 5),
  ];

  void _openOrders(int tab) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UserOrdersScreen(initialTab: tab)),
    );
  }



  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.t('Log out?')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(S.t('Cancel'))),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(S.t('Log out'))),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    AuthService().logout();
    CartService().clearLocal();
    SettingsService().resetToDefaults();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _menuTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(context.tr(label)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = AuthService().currentUsername ?? S.t('Guest');

    return SafeArea(
      child: ResponsiveCenter(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(context.tr('Profile'),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            ),

            
            Row(
              children: [
                UserAvatar(radius: 32, name: username),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(context.tr('My Orders'),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _openOrders(0),
                          child: Text(context.tr('View all')),
                        ),
                      ],
                    ),
                    StreamBuilder<List<AppOrder>>(
                      stream: _stream,
                      builder: (context, snapshot) {
                        final orders = snapshot.data ?? const <AppOrder>[];

                        int countFor(String status) => orders
                            .where((o) =>
                                o.status.toLowerCase() ==
                                status.toLowerCase())
                            .length;

                                             return Row(
                          children: [
                            for (final s in _statusShortcuts)
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => _openOrders(s.$3),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 2),
                                    child: Column(
                                      children: [
                                        Badge(
                                          isLabelVisible: countFor(s.$1) > 0,
                                          label: Text('${countFor(s.$1)}'),
                                          child: Icon(s.$2, size: 28),
                                        ),
                                        const SizedBox(height: 4),
                                        SizedBox(
                                          height: 16,
                                          width: double.infinity,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              context.tr(s.$1),
                                              maxLines: 1,
                                              softWrap: false,
                                              style: const TextStyle(
                                                  fontSize: 11),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            _menuTile(Icons.edit_outlined, 'Edit Profile', () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            }),
           _menuTile(Icons.confirmation_number_outlined, 'Vouchers', () {
                              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VouchersScreen()),
                );
                            }),
            _menuTile(Icons.storefront_outlined, 'My Store', () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const ManageProductsScreen()),
              );
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(context.tr('Log out'),
                  style: const TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}