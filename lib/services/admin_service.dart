import 'package:firebase_database/firebase_database.dart';
import '../models/app_user.dart';
import '../utils/validators.dart';
import 'auth_service.dart';

class AdminService {
  static final _db = FirebaseDatabase.instance;
  static DatabaseReference get _users => _db.ref('users');

  static String _clean(String s) => s.replaceAll(RegExp(r'[.#$\[\]/]'), '_');

  static void _requireAdmin() {
    if (!AuthService().isAdmin) throw 'Admins only';
  }

  static Stream<List<AppUser>> usersStream() {
    return _users.onValue.map((event) {
      final raw = event.snapshot.value;
      final list = <AppUser>[];
      if (raw is Map) {
        raw.forEach((k, v) {
          if (v is Map) {
            list.add(AppUser.fromMap(
                k.toString(), Map<dynamic, dynamic>.from(v)));
          }
        });
      }
      list.sort((a, b) =>
          a.username.toLowerCase().compareTo(b.username.toLowerCase()));
      return list;
    });
  }

  static Stream<int> countStream(String node) =>
      _db.ref(node).onValue.map((e) => e.snapshot.children.length);

  /// All methods return null on success, or an error message.
  static Future<String?> createUser({
    required String username,
    required String contact,
    required String password,
    String fullName = '',
    String address = '',
  }) async {
    try {
      _requireAdmin();
      final name = username.trim();
      final nameError = Validators.username(name);
      if (nameError != null) return nameError;
      if (contact.trim().isEmpty) {
        return 'Email or contact number cannot be empty';
      }
      final pwError = Validators.password(password);
      if (pwError != null) return pwError;
      if (address.trim().isNotEmpty) {
        final e = Validators.address(address);
        if (e != null) return e;
      }

      final snap = await _users.get();
      if (snap.value is Map) {
        for (final v in (snap.value as Map).values) {
          if (v is Map && v['username']?.toString() == name) {
            return 'Username is already taken';
          }
        }
      }

      final fields = AuthService().newPasswordFields(password)
        ..remove('password');
      await _users.push().set({
        'username': name,
        'contact': contact.trim(),
        if (fullName.trim().isNotEmpty) 'fullName': fullName.trim(),
        if (address.trim().isNotEmpty) 'address': address.trim(),
        ...fields,
      });
      return null;
    } catch (e) {
      return 'Could not create account: $e';
    }
  }

  static Future<String?> updateUser(
    AppUser u, {
    required String fullName,
    required String contact,
    required String address,
  }) async {
    try {
      _requireAdmin();
      if (contact.trim().isEmpty) {
        return 'Email or contact number cannot be empty';
      }
      if (address.trim().isNotEmpty) {
        final e = Validators.address(address);
        if (e != null) return e;
      }
      await _users.child(u.key).update({
        'fullName': fullName.trim(),
        'contact': contact.trim(),
        'address': address.trim(),
      });
      return null;
    } catch (e) {
      return 'Could not save: $e';
    }
  }

  static Future<String?> resetPassword(AppUser u, String newPassword) async {
    try {
      _requireAdmin();
      final pwError = Validators.password(newPassword);
      if (pwError != null) return pwError;
      await _users
          .child(u.key)
          .update(AuthService().newPasswordFields(newPassword));
      return null;
    } catch (e) {
      return 'Could not reset password: $e';
    }
  }

  static Future<String?> deleteUser(AppUser u,
      {bool deleteListings = false}) async {
    try {
      _requireAdmin();
      if (u.isAdmin) return 'Admin accounts cannot be deleted here';
      if (u.username == AuthService().currentUsername) {
        return 'You cannot delete your own account';
      }

      final updates = <String, Object?>{
        'users/${u.key}': null,
        'carts/${_clean(u.username)}': null,
        'notifRead/${_clean(u.username)}': null,
      };
      if (deleteListings) {
        final prods = await _db.ref('products').get();
        if (prods.value is Map) {
          (prods.value as Map).forEach((k, v) {
            if (v is Map && v['seller']?.toString() == u.username) {
              updates['products/$k'] = null;
            }
          });
        }
      }
      await _db.ref().update(updates);
      return null;
    } catch (e) {
      return 'Could not delete: $e';
    }
  }
}