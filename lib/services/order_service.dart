import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import  '../models/app_order.dart';
import 'auth_service.dart';
import 'product_service.dart';

class OrderService {static Stream
  <List<AppOrder>> _fromNode(String node, String user) {
    return FirebaseDatabase.instance.ref(node).onValue.map((event) {
      final raw = event.snapshot.value;
      final list = <AppOrder>[];
      if (raw is Map) {
        raw.forEach((key, value) {
          if (value is Map) {
            final o = AppOrder.fromMap(
              key.toString(),Map<dynamic, dynamic>.from(value),
              node: node,);

            if (o.username == user) {
              list.add(o);
            }
          }
        });
      }
      return list;  
    });
    
  }

  
static const autoShipAfter = Duration(seconds: 10);

static Future<void> autoAdvance(List<AppOrder> orders) async {
  final now = DateTime.now().millisecondsSinceEpoch;
  for (final o in orders) {
    if (o.node != 'orders') continue; 
    if (o.status.toLowerCase() != 'processing') continue;
    if (o.createdAt <= 0) continue;
    if (now - o.createdAt < autoShipAfter.inMilliseconds) continue;

    
    
    await FirebaseDatabase.instance
        .ref('${o.node}/${o.id}/status')
        .runTransaction((current) {
      if (current?.toString().toLowerCase() == 'processing') {
        return Transaction.success('Shipping');
      }
      return Transaction.abort();
    });
  }
}
  
   static Stream<List<AppOrder>> streamForCurrentUser() {
    final user = AuthService().currentUsername ?? 'guest';
    List<AppOrder> orders = [];
    List<AppOrder> preorders = [];
    StreamSubscription<List<AppOrder>>? a;
    StreamSubscription<List<AppOrder>>? b;
    late final StreamController<List<AppOrder>> controller;

    void emit() {
      final all = [...orders, ...preorders]
        ..sort((x, y) => y.createdAt.compareTo(x.createdAt));
      if (!controller.isClosed) controller.add(all);
    }

    
    controller = StreamController<List<AppOrder>>.broadcast(
      onListen: () {
        emit(); 
        a = _fromNode('orders', user).listen((l) {
          orders = l;
          emit();
        }, onError: (e) {
          
          print('ORDERS READ FAILED (orders): $e');
          emit();
        });
        b = _fromNode('preorders', user).listen((l) {
          preorders = l;
          emit();
        }, onError: (e) {
          
          print('ORDERS READ FAILED (preorders): $e');
          emit();
        });
      },
      onCancel: () {
        a?.cancel();
        b?.cancel();
      },
    );
    return controller.stream;
  }


  static Future<void> cancel(AppOrder order) async {
  final ref = FirebaseDatabase.instance.ref('${order.node}/${order.id}');

 final result = await ref.child('status').runTransaction((current) {
  if (current == null) return Transaction.success(current); 
  final s = current.toString().toLowerCase();
  if (s == 'processing' || s == 'pre-order' || s == 'shipping') {
    return Transaction.success('Cancelled');
  }
  return Transaction.abort();
});
  if (!result.committed) {
    throw 'This order can no longer be cancelled';
  }

  
  if (order.node == 'orders') {
    for (final i in order.items) {
      if (i.productId.isNotEmpty && i.quantity > 0) {
        await ProductService.restoreStock(i.productId, i.quantity);
      }
    }
  }
}
  }
    