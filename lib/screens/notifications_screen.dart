import 'package:flutter/material.dart';
import '../services/notifications_service.dart';
import 'user_orders_screen.dart';
import '../utils/responsive.dart';
import '../utils/strings.dart';
import '../models/app_order.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final Stream<List<AppNotification>> _stream =
      NotificationService.stream();

  IconData _icon(String status) {
    switch (status.toLowerCase()) {
      case 'pre-order':
        return Icons.schedule;
      case 'processing':
        return Icons.inventory_2_outlined;
      case 'shipping':
        return Icons.local_shipping_outlined;
      case 'received':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color _color(String status) {
    switch (status.toLowerCase()) {
      case 'pre-order':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipping':
        return Colors.purple;
      case 'received':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Matches the tab order in UserOrdersScreen
  int _tabFor(String status) {
    switch (status.toLowerCase()) {
      case 'pre-order':
        return 1;
      case 'processing':
        return 2;
      case 'shipping':
        return 3;
      case 'received':
        return 4;
      case 'cancelled':
        return 5;
      default:
        return 0;
    }
  }

  String _date(int ms) {
    if (ms <= 0) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

    (String, String) _text(AppOrder o) {
    final id = o.id.length > 8 ? o.id.substring(0, 8) : o.id;
    switch (o.status.toLowerCase()) {
      case 'pre-order':
        return (
          S.t('Pre-order placed'),
          S.t('Your pre-order #{id} has been received.', {'id': id})
        );
      case 'processing':
        return (
          S.t('Order processing'),
          S.t('Your order #{id} is being processed.', {'id': id})
        );
      case 'shipping':
        return (
          S.t('Order shipped'),
          S.t('Your order #{id} is on its way.', {'id': id})
        );
      case 'received':
        return (
          S.t('Order received'),
          S.t('Your order #{id} was received. Enjoy!', {'id': id})
        );
      case 'cancelled':
        return (
          S.t('Order cancelled'),
          S.t('Your order #{id} was cancelled.', {'id': id})
        );
      default:
        return (
          S.t('Order update'),
          S.t('Order #{id} is now {status}.', {'id': id, 'status': o.status})
        );
    }
  }

    @override
  Widget build(BuildContext context) {
    LangScope.watch(context); // rebuild when the language changes

    return SafeArea(
      child: StreamBuilder<List<AppNotification>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data!;
          final unreadCount = list.where((n) => n.unread).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveCenter(
                maxWidth: 700,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                  child: Row(
                    children: [
                      Text(context.tr('Notifications'),
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton(
                        onPressed: unreadCount == 0
                            ? null
                            : () => NotificationService.markAllRead(list),
                        child: Text(context.tr('Mark all as read')),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? Center(child: Text(context.tr('No notifications yet')))
                    : ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final n = list[i];
                          final order = n.order;
                          final status = order?.status ?? '';

                          final IconData icon = n.isStock
                              ? Icons.inventory_2_outlined
                              : _icon(status);
                          final Color color =
                              n.isStock ? Colors.red : _color(status);
                          final String when = n.isStock
                              ? _date(n.createdAt)
                              : _date(order?.createdAt ?? 0);

                          // Translate at display time. Order notifications are
                          // built from the status, stock ones go through the
                          // dictionary as-is.
                          final String title = (!n.isStock && order != null)
                              ? _text(order).$1
                              : S.t(n.title);
                          final String message = (!n.isStock && order != null)
                              ? _text(order).$2
                              : S.t(n.message);

                          return ListTile(
                            tileColor: n.unread
                                ? Colors.blue.withValues(alpha: 0.06)
                                : null,
                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: 0.12),
                              child: Icon(icon, color: color),
                            ),
                            title: Text(title,
                                style: TextStyle(
                                    fontWeight: n.unread
                                        ? FontWeight.bold
                                        : FontWeight.w500)),
                            subtitle: Text('$message\n$when'),
                            isThreeLine: true,
                            trailing: n.unread
                                ? const Icon(Icons.circle,
                                    size: 10, color: Colors.blue)
                                : null,
                            onTap: () {
                              if (n.isStock) {
                                NotificationService.markStockRead(n.stockKey!);
                                return;
                              }
                              if (order == null) return;
                              NotificationService.markRead(order);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => UserOrdersScreen(
                                      initialTab: _tabFor(status)),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}