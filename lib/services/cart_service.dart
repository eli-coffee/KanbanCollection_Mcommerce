import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'auth_service.dart';


class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final bool preorder;      
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl = '',
    this.preorder = false,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'preorder' : preorder,
        'quantity': quantity,
      };
}

class CartService extends ChangeNotifier {
  CartService._();
  static final CartService instance = CartService._();
  factory CartService() => instance;
  
  
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get totalCount => _items.fold(0, (s, i) => s + i.quantity);
  double get total => _items.fold(0.0, (s, i) => s + i.price * i.quantity);

  // Firebase keys can't contain . # $ [ ] /
  String _clean(String s) => s.replaceAll(RegExp(r'[.#$\[\]/]'), '_');

  DatabaseReference? get _ref {
    final user = AuthService().currentUsername;
    if (user == null) return null;
    return FirebaseDatabase.instance.ref('carts/${_clean(user)}');
  }

  /// Call right after login/signup to load this user's saved cart.
  Future<void> load() async {
    _items.clear();
    final ref = _ref;
    if (ref != null) {
      final snap = await ref.get();
      final raw = snap.value;
      if (raw is Map) {
        raw.forEach((key, value) {
          if (value is Map) {
            _items.add(CartItem(
              id: key.toString(),
              name: value['name']?.toString() ?? 'Unnamed',
              price: (value['price'] as num?)?.toDouble() ?? 0,
              imageUrl: value['imageUrl']?.toString() ?? '',
              preorder: value['preorder'] == true,
              quantity: (value['quantity'] as num?)?.toInt() ?? 1,
            ));
          }
        });
      }
    }
    notifyListeners();
  }

  /// Call on logout so the next user doesn't see this cart.
  void clearLocal() {
    _items.clear();
    notifyListeners();
  }

  Future<void> add(Product p, {int quantity = 1}) async {
    final id = _clean(p.id.isEmpty ? p.name : p.id);
    final index = _items.indexWhere((i) => i.id == id);
    final CartItem item;
    if (index >= 0) {
      item = _items[index];
      item.quantity += quantity;
    } else {
      item = CartItem(
        id: id,
        name: p.name,
        price: p.price,
        imageUrl: p.imageUrl,
        preorder: p.preorder,
        quantity: quantity,
      );
      _items.add(item);
    }
    notifyListeners();
    await _ref?.child(item.id).set(item.toMap());
  }

  Future<void> increase(CartItem item) async {
    item.quantity++;
    notifyListeners();
    await _ref?.child(item.id).set(item.toMap());
  }

  Future<void> decrease(CartItem item) async {
    if (item.quantity > 1) {
      item.quantity--;
      notifyListeners();
      await _ref?.child(item.id).set(item.toMap());
    } else {
      await remove(item);
    }
  }

  Future<void> remove(CartItem item) async {
    _items.remove(item);
    notifyListeners();
    await _ref?.child(item.id).remove();
  }

  Future<void> clear() async {
    _items.clear();
    notifyListeners();
    await _ref?.remove();
  }
}