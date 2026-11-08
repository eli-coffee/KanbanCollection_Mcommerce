class Validators {
  static const usernameMin = 3;
  static const usernameMax = 20;
  static const passwordMin = 8;
  static const passwordMax = 32;

  /// Returns null if valid, otherwise an error message.
  static String? username(String v) {
    if (v.length < usernameMin) {
      return 'Username must be at least $usernameMin characters';
    }
    if (v.length > usernameMax) {
      return 'Username must be at most $usernameMax characters';
    }
    if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(v)) {
      return 'Username can only use letters, numbers, and underscores';
    }
    return null;
  }

  static String? password(String v) {
    if (v.length < passwordMin) {
      return 'Password must be at least $passwordMin characters';
    }
    if (v.length > passwordMax) {
      return 'Password must be at most $passwordMax characters';
    }
    if (v.contains(' ')) return 'Password cannot contain spaces';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Password must include at least one letter and one number';
    }
    return null;
  }

  static final _emailRe =
    RegExp(r'^[\w.+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$');


/// Returns an error message key, or null if the contact is valid.
static String? contact(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return 'Email or contact number cannot be empty';

  if (s.contains('@')) {
    return _emailRe.hasMatch(s) ? null : 'Enter a valid email address';
  }

  return 'Enter a valid email address';
}

  static const addressMin = 10;
  static const addressMax = 200;

  static String? address(String v) {
    final t = v.trim();
    if (t.isEmpty) return 'Please add a delivery address';
    if (t.length < addressMin) {
      return 'Address is too short. Include street, barangay, city, and province';
    }
    if (t.length > addressMax) return 'Address is too long';
    return null;
  }
}