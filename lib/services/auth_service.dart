import 'dart:convert';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import '../utils/validators.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();
  factory AuthService() => instance;

  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');

  String? _loggedInUsername;
  String? _loggedInKey;
  
   bool _isAdmin = false;
   bool get isAdmin => _isAdmin;

  
   Map<String, Object?> newPasswordFields(String password) =>
      _passwordFields(password);
  
  final ValueNotifier<String?> photo = ValueNotifier<String?>(null);

  String? get currentUsername => _loggedInUsername;
  bool get isLoggedIn => _loggedInUsername != null;

  String _clean(String s) => s.replaceAll(RegExp(r'[.#$\[\]/]'), '_');

   String _newSalt() {
    final rnd = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => rnd.nextInt(256)));
  }

  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  
  
  bool _verify(Map user, String password) {
    final hash = user['passwordHash']?.toString();
    final salt = user['salt']?.toString();
    if (hash != null && hash.isNotEmpty && salt != null && salt.isNotEmpty) {
      return _hash(password, salt) == hash;
    }
    return user['password']?.toString() == password; 
  }

  Map<String, Object?> _passwordFields(String password) {
    final salt = _newSalt();
    return {
      'passwordHash': _hash(password, salt),
      'salt': salt,
      'password': null, 
    };
  }

  
  Future<String?> login(String username, String password) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty) return 'Username cannot be empty';
    if (password.isEmpty) return 'Password cannot be empty';

    try {
      final snapshot = await _usersRef.get();
      if (!snapshot.exists) return 'Incorrect username or password';

      final allUsers = Map<dynamic, dynamic>.from(snapshot.value as Map);
      for (final entry in allUsers.entries) {
        final userData = Map<dynamic, dynamic>.from(entry.value as Map);

        
        final storedName = userData['username']?.toString() ?? '';
        final storedContact = userData['contact']?.toString() ?? '';
        if ((storedName == trimmedUsername || storedContact == trimmedUsername) &&
            _verify(userData, password)) {
          _loggedInUsername = storedName;      
          _loggedInKey = entry.key.toString();
         _isAdmin =
         userData['role']?.toString().trim().toLowerCase() == 'admin';
         debugPrint('LOGIN: user=$storedName key=${entry.key} role=${userData['role']} admin=$_isAdmin');

                    
          final hasHash =
              (userData['passwordHash']?.toString() ?? '').isNotEmpty;
          if (!hasHash) {
            await _usersRef
                .child(_loggedInKey!)
                .update(_passwordFields(password));
          }

          return null;
        }
      }
      return 'Incorrect username or password';
    } catch (e) {
      return 'Login failed: $e';
    }
  }

  
  Future<String?> register(
      String username, String contact, String password) async {
    final trimmedUsername = username.trim();
    final trimmedContact = contact.trim();

       final nameError = Validators.username(trimmedUsername);
    if (nameError != null) return nameError;
    if (trimmedContact.isEmpty) {
      return 'Email or contact number cannot be empty';
    }
    final pwError = Validators.password(password);
    if (pwError != null) return pwError;

    try {
      final snapshot = await _usersRef.get();
      if (snapshot.exists) {
        final allUsers = Map<dynamic, dynamic>.from(snapshot.value as Map);
        for (final entry in allUsers.values) {
          final userData = Map<dynamic, dynamic>.from(entry as Map);
          if (userData['username']?.toString() == trimmedUsername) {
            return 'Username is already taken';
          }
        }
      }

         final newRef = _usersRef.push();      
         final fields = _passwordFields(password)..remove('password');      
         await newRef.set({
        'username': trimmedUsername,
        'contact': trimmedContact,
        ...fields
      });

      _loggedInUsername = trimmedUsername;
      _loggedInKey = newRef.key;
      _isAdmin = false;
      return null;
    } catch (e) {
      return 'Sign up failed: $e';
    }
  }

  void logout() {
    _loggedInUsername = null;
    _loggedInKey = null;
    photo.value = null;
    _isAdmin = false;
  }

  
   Future<Map<String, String>> getProfile() async {
    if (_loggedInKey == null) return {};
    final snap = await _usersRef.child(_loggedInKey!).get();
    final raw = snap.value;
    if (raw is! Map) return {};
    return {
      'fullName': raw['fullName']?.toString() ?? '',
      'contact': raw['contact']?.toString() ?? '',
      'address': raw['address']?.toString() ?? '',
    };
  }

  Future<String?> updateProfile({
    required String fullName,
    required String contact,
    String? address, 
  }) async {
    if (_loggedInKey == null) return 'You are not logged in';
    if (contact.trim().isEmpty) {
      return 'Email or contact number cannot be empty';
    }
    try {
      final data = <String, Object?>{
        'fullName': fullName.trim(),
        'contact': contact.trim(),
      };
      if (address != null) data['address'] = address.trim();
      await _usersRef.child(_loggedInKey!).update(data);
      return null;
    } catch (e) {
      return 'Could not save: $e';
    }
  }

    Future<String> getAddress() async {
    if (_loggedInKey == null) return '';
    final snap = await _usersRef.child(_loggedInKey!).child('address').get();
    return snap.value?.toString() ?? '';
  }

  Future<String?> updateAddress(String address) async {
    if (_loggedInKey == null) return 'You are not logged in';
    try {
      await _usersRef
          .child(_loggedInKey!)
          .update({'address': address.trim()});
      return null;
    } catch (e) {
      return 'Could not save: $e';
    }
  }

   Future<String?> changePassword(
      {required String current, required String newPassword}) async {
    if (_loggedInKey == null) return 'You are not logged in';
    final pwError = Validators.password(newPassword);
    if (pwError != null) return pwError;

    try {
      final snap = await _usersRef.child(_loggedInKey!).get();
      final raw = snap.value;
      if (raw is! Map) return 'Account not found';
      if (!_verify(raw, current)) return 'Current password is incorrect';

      await _usersRef.child(_loggedInKey!).update(_passwordFields(newPassword));
      return null;
    } catch (e) {
      return 'Could not change password: $e';
    }
  }
  
  Future<String?> changeUsername(
      {required String newUsername, required String password}) async {
    final oldName = _loggedInUsername;
    if (oldName == null) return 'You are not logged in';

    final newName = newUsername.trim();
    final nameError = Validators.username(newName);
    if (nameError != null) return nameError;
    if (newName == oldName) return 'That is already your username';

    try {
      final db = FirebaseDatabase.instance;

      final all = await _usersRef.get();
      if (all.value is! Map) return 'Account not found';

      String? matchedKey;
      for (final entry in (all.value as Map).entries) {
        final v = entry.value;
             if (v is Map &&
            v['username']?.toString() == oldName &&
            _verify(v, password)) {
          matchedKey = entry.key.toString();
          break;
        }
      }
      if (matchedKey == null) return 'Password is incorrect';

      for (final v in (all.value as Map).values) {
        if (v is Map && v['username']?.toString() == newName) {
          return 'Username is already taken';
        }
      }

      final updates = <String, Object?>{
        'users/$matchedKey/username': newName,
      };

      for (final node in ['orders', 'preorders']) {
        final snap = await db.ref(node).get();
        if (snap.value is Map) {
          (snap.value as Map).forEach((k, v) {
            if (v is Map && v['username']?.toString() == oldName) {
              updates['$node/$k/username'] = newName;
            }
          });
        }
      }

      final prods = await db.ref('products').get();
      if (prods.value is Map) {
        (prods.value as Map).forEach((k, v) {
          if (v is Map && v['seller']?.toString() == oldName) {
            updates['products/$k/seller'] = newName;
          }
        });
      }

      for (final node in ['carts', 'notifRead']) {
        final snap = await db.ref('$node/${_clean(oldName)}').get();
        if (snap.exists) {
          updates['$node/${_clean(newName)}'] = snap.value;
          updates['$node/${_clean(oldName)}'] = null;
        }
      }

      await db.ref().update(updates);

      _loggedInUsername = newName;
      _loggedInKey = matchedKey;
      return null;
    } catch (e) {
      return 'Could not change username: $e';
    }
  }

  
  Future<void> loadPhoto() async {
    if (_loggedInKey == null) {
      photo.value = null;
      return;
    }
    final snap = await _usersRef.child(_loggedInKey!).child('photo').get();
    final v = snap.value?.toString();
    photo.value = (v == null || v.isEmpty) ? null : v;
  }

  Future<String?> updatePhoto(Uint8List bytes) async {
    if (_loggedInKey == null) return 'You are not logged in';
    if (bytes.length > 300 * 1024) {
      return 'Image is too large. Please pick a smaller one.';
    }
    try {
      final b64 = base64Encode(bytes);
      await _usersRef.child(_loggedInKey!).update({'photo': b64});
      photo.value = b64;
      return null;
    } catch (e) {
      return 'Could not save photo: $e';
    }
  }

  Future<String?> removePhoto() async {
    if (_loggedInKey == null) return 'You are not logged in';
    try {
      await _usersRef.child(_loggedInKey!).update({'photo': null});
      photo.value = null;
      return null;
    } catch (e) {
      return 'Could not remove photo: $e';
    }
  }
}
