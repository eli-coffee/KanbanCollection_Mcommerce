import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/app_order.dart';
import 'auth_service.dart';
import 'order_service.dart';

class AppNotification {
  final AppOrder? order;      // set for order notifications
  final String? stockKey;     // set for sold-out alerts (key under notifications/<seller>)
  final String title;
  final String message;
  final bool unread;
  final int createdAt;

  const AppNotification({
    this.order,
    this.stockKey,
    required this.title,
    required this.message,
    required this.unread,
    this.createdAt = 0,
  });

  bool get isStock => stockKey != null;
}

class NotificationService {
  static String _clean(String s) => s.replaceAll(RegExp(r'[.#$\[\]/]'), '_');

  static String get _user => AuthService().currentUsername ?? 'guest';

  static DatabaseReference _readRef() =>
      FirebaseDatabase.instance.ref('notifRead/${_clean(_user)}');

  static DatabaseReference _stockRef() =>
      FirebaseDatabase.instance.ref('notifications/${_clean(_user)}');

  static String _shortId(String id) => id.length > 8 ? id.substring(0, 8) : id;

  static (String, String) _text(AppOrder o) {
    final id = _shortId(o.id);
    switch (o.status.toLowerCase()) {
      case 'pre-order':
        return ('Pre-order placed', 'Your pre-order #$id has been received.');
      case 'processing':
        return ('Order processing', 'Your order #$id is being processed.');
      case 'shipping':
        return ('Order shipped', 'Your order #$id is on its way.');
      case 'received':
        return ('Order received', 'Your order #$id was received. Enjoy!');
      case 'cancelled':
        return ('Order cancelled', 'Your order #$id was cancelled.');
      default:
        return ('Order update', 'Order #$id is now ${o.status}.');
    }
  }

  /// Called when a product's stock reaches 0 (see ProductService.deductStock).
  static Future<void> notifyOutOfStock({
    required String seller,
    required String productId,
    required String productName,
  }) {
    return FirebaseDatabase.instance
        .ref('notifications/${_clean(seller)}')
        .push()
        .set({
      'title': 'Out of stock',
      'message': '"$productName" has run out of stock.',
      'productId': productId,
      'read': false,
      'createdAt': ServerValue.timestamp,
    });
  }

  /// Live notifications for the logged-in user: sold-out alerts first,
  /// then order updates.
  static Stream<List<AppNotification>> stream() {
    List<AppOrder> orders = [];
    List<AppNotification> stock = [];
    Map<String, String> read = {};
    bool readLoaded = false;
    StreamSubscription<List<AppOrder>>? a;
    StreamSubscription<DatabaseEvent>? b;
    StreamSubscription<DatabaseEvent>? c;
    late final StreamController<List<AppNotification>> controller;

    void emit() {
      if (!readLoaded || controller.isClosed) return;
      final list = <AppNotification>[...stock];
      for (final o in orders) {
        final t = _text(o);
        list.add(AppNotification(
          order: o,
          title: t.$1,
          message: t.$2,
          unread: read[o.id] != o.status,
        ));
      }
      controller.add(list);
    }

    controller = StreamController<List<AppNotification>>(
      onListen: () {
        a = OrderService.streamForCurrentUser().listen((l) {
          orders = l;
          emit();
        }, onError: (_) {});

        b = _readRef().onValue.listen((event) {
          final raw = event.snapshot.value;
          read = {};
          if (raw is Map) {
            raw.forEach((k, v) => read[k.toString()] = v.toString());
          }
          readLoaded = true;
          emit();
        }, onError: (_) {
          readLoaded = true;
          emit();
        });

        c = _stockRef().onValue.listen((event) {
          final raw = event.snapshot.value;
          final items = <AppNotification>[];
          if (raw is Map) {
            raw.forEach((k, v) {
              if (v is Map) {
                items.add(AppNotification(
                  stockKey: k.toString(),
                  title: v['title']?.toString() ?? 'Out of stock',
                  message: v['message']?.toString() ?? '',
                  unread: v['read'] != true,
                  createdAt: (v['createdAt'] as num?)?.toInt() ?? 0,
                ));
              }
            });
          }
          items.sort((x, y) => y.createdAt.compareTo(x.createdAt));
          stock = items;
          emit();
        }, onError: (_) {});
      },
      onCancel: () {
        a?.cancel();
        b?.cancel();
        c?.cancel();
      },
    );
    return controller.stream;
  }

  static Future<void> markRead(AppOrder o) =>
      _readRef().child(o.id).set(o.status);

  static Future<void> markStockRead(String key) =>
      _stockRef().child(key).child('read').set(true);

  static Future<void> markAllRead(List<AppNotification> list) {
    final updates = <String, Object?>{};
    for (final n in list.where((n) => n.unread)) {
      if (n.isStock) {
        updates['notifications/${_clean(_user)}/${n.stockKey}/read'] = true;
      } else if (n.order != null) {
        updates['notifRead/${_clean(_user)}/${n.order!.id}'] = n.order!.status;
      }
    }
    if (updates.isEmpty) return Future.value();
    return FirebaseDatabase.instance.ref().update(updates);
  }
}