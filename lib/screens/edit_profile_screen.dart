import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_shell.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/user_avatar.dart';
import '../utils/validators.dart';
import '../utils/responsive.dart';
import '../utils/strings.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = AuthService();

  final _fullNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _currentPwController = TextEditingController();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();
  final _usernameController = TextEditingController();
  final _usernamePwController = TextEditingController();
  final _addressController = TextEditingController();
  
  bool _savingUsername = false;

  bool _savingProfile = false;
  bool _savingPassword = false;
  bool _obscure = true;
  bool _savingPhoto = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await _auth.getProfile();
    if (!mounted) return;
    setState(() {
      _fullNameController.text = profile['fullName'] ?? '';
      _contactController.text = profile['contact'] ?? '';
      _usernameController.text = _auth.currentUsername ?? '';
      _addressController.text = profile['address'] ?? '';
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _contactController.dispose();
    _currentPwController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    _usernameController.dispose();
    _usernamePwController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(S.t(text))));
  }

   Future<void> _saveProfile() async {
    final address = _addressController.text.trim();
    if (address.isNotEmpty) {
      final addressError = Validators.address(address);
      if (addressError != null) {
        _snack(addressError);
        return;
      }
    }
    setState(() => _savingProfile = true);
    final error = await _auth.updateProfile(
      fullName: _fullNameController.text,
      contact: _contactController.text,
      address: address,
    );
    if (!mounted) return;
    setState(() => _savingProfile = false);
    _snack(error ?? 'Profile updated');
  }

  Future<void> _changePassword() async {
    if (_currentPwController.text.isEmpty ||
        _newPwController.text.isEmpty ||
        _confirmPwController.text.isEmpty) {
      _snack('Please fill in all password fields');
      return;
    }
    if (_newPwController.text != _confirmPwController.text) {
      _snack('New passwords do not match');
      return;
    }

    setState(() => _savingPassword = true);
    final error = await _auth.changePassword(
      current: _currentPwController.text,
      newPassword: _newPwController.text,
    );
    if (!mounted) return;
    setState(() => _savingPassword = false);

    if (error == null) {
      _currentPwController.clear();
      _newPwController.clear();
      _confirmPwController.clear();
      _snack('Password changed');
    } else {
      _snack(error);
    }
  }

  Future<void> _changeUsername() async {
    final newName = _usernameController.text.trim();
    if (newName.isEmpty) {
      _snack('Username cannot be empty');
      return;
    }
    if (newName == _auth.currentUsername) {
      _snack('That is already your username');
      return;
    }
    if (_usernamePwController.text.isEmpty) {
      _snack('Enter your password to change your username');
      return;
    }

    setState(() => _savingUsername = true);
    final error = await _auth.changeUsername(
      newUsername: newName,
      password: _usernamePwController.text,
    );
    if (!mounted) return;
    setState(() => _savingUsername = false);

    if (error != null) {
      _snack(error);
      return;
    }

    _usernamePwController.clear();
    _snack(S.t('Username changed to {name}', {'name': newName}));

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  InputDecoration _decoration(String label, {Widget? suffix, String? helper}) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 75,
    );
    if (file == null) return;

    setState(() => _savingPhoto = true);
    final bytes = await file.readAsBytes();
    final error = await _auth.updatePhoto(bytes);
    if (!mounted) return;
    setState(() => _savingPhoto = false);
    _snack(error ?? 'Profile picture updated');
  }

  Future<void> _removePhoto() async {
    setState(() => _savingPhoto = true);
    final error = await _auth.removePhoto();
    if (!mounted) return;
    setState(() => _savingPhoto = false);
    _snack(error ?? 'Profile picture removed');
  }

  void _photoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(S.t('Choose from gallery')),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto();
              },
            ),
            if (_auth.photo.value != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  S.t('Remove photo'),
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = _auth.currentUsername ?? 'Guest';

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Edit Profile')), centerTitle: true),
      body: ResponsiveCenter(
        maxWidth: 600,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: _savingPhoto ? null : _photoOptions,
                child: Stack(
                  children: [
                    UserAvatar(radius: 48, name: username),
                    if (_savingPhoto)
                      const Positioned.fill(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              context.tr('Username'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usernameController,
              maxLength: Validators.usernameMax,
              decoration: _decoration(
                context.tr('Username'),
                helper:
                    '${Validators.usernameMin}-${Validators.usernameMax} characters: letters, numbers, _',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usernamePwController,
              obscureText: _obscure,
              decoration: _decoration(
                context.tr('Password (required to change username)'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _savingUsername ? null : _changeUsername,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _savingUsername
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.tr('Update username')),
              ),
            ),
            const Divider(height: 40),

            Text(
              context.tr('Account details'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _fullNameController,
              textCapitalization: TextCapitalization.words,
              decoration: _decoration(context.tr('Full name')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contactController,
              keyboardType: TextInputType.emailAddress,
              decoration: _decoration(context.tr('Email or Contact Number')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              maxLines: 3,
              maxLength: Validators.addressMax,
              textCapitalization: TextCapitalization.words,
              decoration: _decoration(
                'Delivery address',
                helper: 'House no., street, barangay, city, province, postal code',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _savingProfile ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _savingProfile
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.tr('Save changes')),
              ),
            ),

            const Divider(height: 40),

            Text(
              context.tr('Change password'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _currentPwController,
              obscureText: _obscure,
              decoration: _decoration(
                context.tr('Current password'),
                suffix: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPwController,
              obscureText: _obscure,
              decoration: _decoration(
                context.tr('New password'),
                helper:
                    '${Validators.passwordMin}-${Validators.passwordMax} characters, with a letter and a number',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPwController,
              obscureText: _obscure,
              decoration: _decoration(context.tr('Confirm new password')),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _savingPassword ? null : _changePassword,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _savingPassword
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.tr('Change password')),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}