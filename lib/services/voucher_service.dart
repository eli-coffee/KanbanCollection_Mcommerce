import 'package:firebase_database/firebase_database.dart';
import 'auth_service.dart';

class Voucher {
  final String id;
  final String title;
  final String description;
  final double? percent;   
  final double? amount;    
  final double minSpend;
  final int expiresAt;     

  const Voucher({
    required this.id,
    required this.title,
    this.description = '',
    this.percent,
    this.amount,
    this.minSpend = 0,
    this.expiresAt = 0,
  });

  factory Voucher.fromMap(String id, Map<dynamic, dynamic> d) => Voucher(
        id: id,
        title: d['title']?.toString() ?? id,
        description: d['description']?.toString() ?? '',
        percent: (d['percent'] as num?)?.toDouble(),
        amount: (d['amount'] as num?)?.toDouble(),
        minSpend: (d['minSpend'] as num?)?.toDouble() ?? 0,
        expiresAt: (d['expiresAt'] as num?)?.toInt() ?? 0,
      );

  bool get expired =>
      expiresAt > 0 && DateTime.now().millisecondsSinceEpoch > expiresAt;

  
  double discountFor(double subtotal) {
    if (subtotal < minSpend) return 0;
    final d = percent != null ? subtotal * percent! / 100 : (amount ?? 0);
    return d > subtotal ? subtotal : d;
  }
}

class VoucherService {
  static String _clean(String s) => s.replaceAll(RegExp(r'[.#$\[\]/]'), '_');

  static DatabaseReference _mine() {
    final user = AuthService().currentUsername ?? 'guest';
    return FirebaseDatabase.instance.ref('userVouchers/${_clean(user)}');
  }

  static Stream<List<Voucher>> streamAll() {
    return FirebaseDatabase.instance.ref('vouchers').onValue.map((e) {
      final raw = e.snapshot.value;
      final list = <Voucher>[];
      if (raw is Map) {
        raw.forEach((k, v) {
          if (v is Map) {
            list.add(Voucher.fromMap(k.toString(), Map<dynamic, dynamic>.from(v)));
          }
        });
      }
      return list;
    });
  }

  static bool promptPending = false;
static bool claimedThisLogin = false;

/// Call after a successful login or sign-up instead of setting the flag by hand.
static void newSession() {
  promptPending = true;
  claimedThisLogin = false;
}

/// voucherId -> how many the user owns.
static Stream<Map<String, int>> streamClaimed() {
  return _mine().onValue.map((e) {
    final raw = e.snapshot.value;
    final out = <String, int>{};
    if (raw is Map) {
      raw.forEach((k, v) {
        final n = v is Map ? (v['count'] as num?)?.toInt() ?? 0 : 0;
        out[k.toString()] = n;
      });
    }
    return out;
  });
}

/// Adds one to the user's stack. Allowed once per login.
static Future<void> claim(Voucher v) async {
  if (AuthService().currentUsername == null) throw 'You are not logged in';
  if (claimedThisLogin) throw 'You can claim one voucher per login';
  await _mine().child(v.id).child('count').runTransaction((cur) {
    final n = (cur as num?)?.toInt() ?? 0;
    return Transaction.success(n + 1);
  });
  claimedThisLogin = true;
}

/// Every active voucher, offered again on each login.
static Future<List<Voucher>> claimable() async {
  final all = await FirebaseDatabase.instance.ref('vouchers').get();
  final list = <Voucher>[];
  if (all.value is Map) {
    (all.value as Map).forEach((k, v) {
      if (v is Map) {
        final voucher =
            Voucher.fromMap(k.toString(), Map<dynamic, dynamic>.from(v));
        if (!voucher.expired) list.add(voucher);
      }
    });
  }
  return list;
}

/// Vouchers the user owns at least one of, not expired.
static Future<List<Voucher>> usable() async {
  final all = await FirebaseDatabase.instance.ref('vouchers').get();
  final mine = await _mine().get();

  final owned = <String>{};
  if (mine.value is Map) {
    (mine.value as Map).forEach((k, v) {
      if (v is Map && ((v['count'] as num?)?.toInt() ?? 0) > 0) {
        owned.add(k.toString());
      }
    });
  }

  final list = <Voucher>[];
  if (all.value is Map) {
    (all.value as Map).forEach((k, v) {
      if (v is Map && owned.contains(k.toString())) {
        final voucher =
            Voucher.fromMap(k.toString(), Map<dynamic, dynamic>.from(v));
        if (!voucher.expired) list.add(voucher);
      }
    });
  }
  return list;
}

/// Spends one voucher from the stack.
static Future<void> use(String id) async {
  final ref = _mine().child(id).child('count');
  final snap = await ref.get();
  final n = (snap.value as num?)?.toInt() ?? 0;
  if (n <= 0) throw 'This voucher can no longer be used';
  await ref.set(n - 1);
}

/// Gives one back (order failed or was cancelled).
static Future<void> restore(String id) async {
  await _mine().child(id).child('count').runTransaction((cur) {
    return Transaction.success(((cur as num?)?.toInt() ?? 0) + 1);
  });
}
}