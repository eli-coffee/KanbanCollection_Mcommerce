import 'package:flutter/material.dart';
import '../models/app_order.dart';
import '../services/order_service.dart';  

class UserOrdersScreen extends StatefulWidget {
  final int initialTab;
  const UserOrdersScreen({super.key, this.initialTab = 0});

  @override
  State<UserOrdersScreen> createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen>{
 static const _tabs = [
  'All', 'Pre-order', 'Processing', 'Shipping', 'Received', 'Cancelled'
 ];

 late final Stream<List<AppOrder>> _stream = OrderService.streamForCurrentUser();

 String _peso(double v) =>
      '₱${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';

  String _date(int ms){
    if (ms <= 0) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
    
  }

    Color _statusColor(String status) {
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
      Future<void> _confirmCancel(AppOrder order) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cancel Order'),
      content: const Text('Are you sure you want to cancel this order?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Yes'),
        ),
      ],
    ),
  );
  if (ok != true) return;
 try {
  await OrderService.cancel(order);
  if (!mounted) return;
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Order cancelled')));
} catch (e) {
  if (!mounted) return;
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('$e')));
}
  }
      Widget _orderCard(AppOrder o) {
        final s = o.status.toLowerCase();
        final canCancel = s == 'processing' || s == 'pre-order' || s == 'shipping';
        final shortId = o.id.length > 8 ? o.id.substring(0, 8) : o.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [Text('Order #$shortId', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                Container(
                  padding: 
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(o.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(o.status, style: TextStyle
                  (color: _statusColor(o.status), fontSize:12, fontWeight:FontWeight.w600)),
                  ),
                  ],
                ),
              
    
          
          
            if (_date(o.createdAt).isNotEmpty)
             Text (_date(o.createdAt), 
             style: const TextStyle(color: Colors.grey, fontSize: 12)),
             const Divider(height: 20),
             for (final i in o.items)
             Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(i.name, 
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14))),
                  Text('${i.quantity}'),
                ],
              ),
          ),
          const Divider(height:20),
          Row(
            children: [
              Text('Total: ${_peso(o.total)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (canCancel) 
                OutlinedButton(
                  onPressed: () => _confirmCancel(o),
                  child: const Text('Cancel Order'),
                ),
            ],
          ),
          ],
          ),
         ),
        );
      }

      @override
      Widget build(BuildContext context) {
        return DefaultTabController(
          initialIndex: widget.initialTab,
          length: _tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('My Orders'),
              centerTitle: true,
              bottom: TabBar(
                isScrollable: true,
                tabs: [for (final t in _tabs) Tab(text: t)],
              ),
            ),
            
            body: StreamBuilder<List<AppOrder>>(
              stream: _stream,
              builder: (context, snapshot) {
                 if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
               
                final orders = snapshot.data!;
                return TabBarView(
                  children: [
                    for (final t in _tabs)
                    Builder(builder: (_){ final list = t == 'All'
                        ? orders
                        : orders.where((o) => o.status.toLowerCase() == t.toLowerCase()).toList();
                    if (list.isEmpty) {
                      return const Center(child: Text('No orders found.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final order = list[index];
                        return _orderCard(order);
                      },
                    );})
                   
                  ]
                );
              },
            ),
          ),
        );
      }
}