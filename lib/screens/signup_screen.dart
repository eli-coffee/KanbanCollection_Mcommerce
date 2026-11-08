import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/brand.dart';
import 'main_shell.dart';
import '../services/cart_service.dart';
import '../services/settings_service.dart';
import '../services/voucher_service.dart';
import '../utils/strings.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  Future<void> _handleSignup() async {
    final username = _usernameController.text.trim();
    final contact = _contactController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    final contactError = Validators.contact(_contactController.text);
    
    if (contactError != null) {
      setState(() => _errorMessage = contactError);
      return;
    }

    if (username.isEmpty ||
        contact.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await _authService.register(username, contact, password);

       if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
      return;
    }

    
    final loginError = await _authService.login(username, password);
    if (!mounted) return;

    if (loginError != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = loginError;
      });
      return;
    }

       await CartService().load();
    await AuthService().loadPhoto();
    await SettingsService().loadForUser();
    if (!mounted) return;

    setState(() => _isLoading = false);
    VoucherService.promptPending = true;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }
  @override
  void dispose() {
    _usernameController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _eye(bool obscured, VoidCallback onTap) => IconButton(
        icon: Icon(obscured ? Icons.visibility_off : Icons.visibility),
        onPressed: onTap,
      );

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: context.tr('Sign up'),
      error: _errorMessage,
      fields: [
        PillField(
          controller: _usernameController,
          label: context.tr('Username'),
          maxLength: Validators.usernameMax,
        ),
        const SizedBox(height: 14),
        PillField(
          controller: _contactController,
          label: context.tr('Email') ,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        PillField(
          controller: _passwordController,
          label: context.tr('Password'),
          obscure: _obscure,
          maxLength: Validators.passwordMax,
          suffix: _eye(_obscure, () => setState(() => _obscure = !_obscure)),
        ),
        const SizedBox(height: 14),
        PillField(
          controller: _confirmController,
          label: context.tr('Confirm Password'),
          obscure: _obscureConfirm,
          maxLength: Validators.passwordMax,
          suffix: _eye(_obscureConfirm,
              () => setState(() => _obscureConfirm = !_obscureConfirm)),
        ),
      ],
      button: PillButton(
        text: 'Get Started',
        loading: _isLoading,
        onPressed: _isLoading ? null : _handleSignup,
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text('${context.tr('Already have an account?')}  ',
    style: const TextStyle(color: Colors.black54)),
GestureDetector(
  onTap: () => Navigator.of(context).pop(),
  child: Text(context.tr('Login'),
      style: const TextStyle(
          color: AppColors.indigo,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}