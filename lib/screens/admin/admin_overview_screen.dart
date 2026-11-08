import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/product.dart';
import '../../services/admin_service.dart';
import '../../services/product_service.dart';

class AdminOverviewScreen extends StatefulWidget {
  const AdminOverviewScreen({super.key});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  late final Stream<List<Product>> _products =
      ProductService.stream().asBroadcastStream();
  late final Stream<List<AppUser>> _users =
      AdminService.usersStream().asBroadcastStream();
  late final Stream<int> _orders =
      AdminService.countStream('orders').asBroadcastStream();
  late final Stream<int> _preorders =
      AdminService.countStream('preorders').asBroadcastStream();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _Stat<List<Product>>(
              label: 'Products',
              icon: Icons.inventory_2_outlined,
              stream: _products,
              value: (l) => '${l.length}',
            ),
            _Stat<List<Product>>(
              label: 'Sold out',
              icon: Icons.remove_shopping_cart_outlined,
              stream: _products,
              value: (l) => '${l.where((p) => p.soldOut).length}',
            ),
            _Stat<List<Product>>(
              label: 'Pre-order items',
              icon: Icons.schedule,
              stream: _products,
              value: (l) => '${l.where((p) => p.preorder).length}',
            ),
            _Stat<List<AppUser>>(
              label: 'Accounts',
              icon: Icons.people_outline,
              stream: _users,
              value: (l) => '${l.length}',
            ),
            _Stat<int>(
              label: 'Orders',
              icon: Icons.receipt_long_outlined,
              stream: _orders,
              value: (n) => '$n',
            ),
            _Stat<int>(
              label: 'Pre-orders',
              icon: Icons.event_available_outlined,
              stream: _preorders,
              value: (n) => '$n',
            ),
          ],
        ),
      ],
    );
  }
}

class _Stat<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final Stream<T> stream;
  final String Function(T) value;

  const _Stat({
    required this.label,
    required this.icon,
    required this.stream,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(child: Icon(icon)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<T>(
                      stream: stream,
                      builder: (_, s) => Text(
                        s.hasData ? value(s.data as T) : '…',
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(label),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}