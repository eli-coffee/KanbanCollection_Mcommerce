import 'package:firebase_database/firebase_database.dart';
import '../models/product.dart';
import 'auth_service.dart';

class ProductService {
  static final DatabaseReference _ref =
      FirebaseDatabase.instance.ref('products');

  
  static const categories = ['Nendoroid', 'Gunpla', 'Figures','Plushies','Keychains','Accessories','Lego','Acryllic Stands'];

  
  
  static const imagePrefix = 'assets/';

  static String assetPath(String stored) =>
      stored.startsWith(imagePrefix) ? stored : '$imagePrefix$stored';

  static String toStored(String assetKey) => assetKey.startsWith(imagePrefix)
      ? assetKey.substring(imagePrefix.length)
      : assetKey;

  
  static Stream<List<Product>> stream() {
    return _ref.onValue.map((event) {
      final raw = event.snapshot.value;
      final list = <Product>[];
      if (raw is Map) {
        raw.forEach((key, value) {
          if (value is Map) {
            list.add(Product.fromMap(
                key.toString(), Map<dynamic, dynamic>.from(value)));
          }
        });
      }
      list.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  
  static Stream<List<Product>> streamForSeller(String seller) =>
      stream().map((l) => l.where((p) => p.seller == seller).toList());

  static String _requireUser() {
    final user = AuthService().currentUsername;
    if (user == null) throw 'You are not logged in';
    return user;
  }

  static Future<void> create(Product p) {
    final user = _requireUser();
    return _ref.push().set({
      ...p.toMap(),
      'seller': user,
      'createdAt': ServerValue.timestamp,
    });
  }

  static Future<void> update(Product p) {
    final user = _requireUser();
    if (p.seller != user && !AuthService().isAdmin) throw 'You can only edit your own products';
    final map = p.toMap()..remove('seller'); 
    return _ref.child(p.id).update(map);
  }

  static Future<void> delete(Product p) {
    final user = _requireUser();
    if (p.seller != user) throw 'You can only delete your own products';
    return _ref.child(p.id).remove();
  }

  

static Future<void> deductStock(String productId, int qty) async {
  final productRef = _ref.child(productId);

  final result = await productRef.child('stock').runTransaction((current) {
    final s = (current as num?)?.toInt();
    if (s == null) return Transaction.success(current); 
    if (s < qty) return Transaction.abort();             
    return Transaction.success(s - qty);
  });

    if (!result.committed) throw 'Not enough stock left';

  final left = (result.snapshot.value as num?)?.toInt();
  if (left == 0) {
    final snap = await productRef.get();
    final data = snap.value;
    if (data is Map) {
      final seller = data['seller']?.toString() ?? '';
      if (seller.isNotEmpty) {
        await FirebaseDatabase.instance
            .ref('notifications/$seller')
            .push()
            .set({
          'title': 'Out of stock',
          'message': '"${data['name']}" has run out of stock.',
          'productId': productId,
          'read': false,
          'createdAt': ServerValue.timestamp,
        });
      }
    }
  }
}
          static Future<void> restoreStock(String productId, int qty) async {
            await _ref.child(productId).child('stock').runTransaction((current) {
              final s = (current as num?)?.toInt();
              if (s == null) return Transaction.success(current);
              return Transaction.success(s + qty);
            });
          }
}