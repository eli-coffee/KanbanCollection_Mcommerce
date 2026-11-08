class AppUser {
  final String key;
  final String username;
  final String fullName;
  final String contact;
  final String address;
  final bool isAdmin;

  const AppUser({
    required this.key,
    required this.username,
    this.fullName = '',
    this.contact = '',
    this.address = '',
    this.isAdmin = false,
  });

  factory AppUser.fromMap(String key, Map<dynamic, dynamic> d) => AppUser(
        key: key,
        username: d['username']?.toString() ?? '',
        fullName: d['fullName']?.toString() ?? '',
        contact: d['contact']?.toString() ?? '',
        address: d['address']?.toString() ?? '',
        isAdmin: d['role']?.toString() == 'admin',
      );
}