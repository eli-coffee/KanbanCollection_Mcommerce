  import 'package:flutter/material.dart';
  import '../services/auth_service.dart';
  import '../services/cart_service.dart';
  import '../widgets/brand.dart';
  import 'main_shell.dart';
  import 'signup_screen.dart';
  import '../theme/app_theme.dart';
  import '../utils/strings.dart';
  import '../screens/admin/admin_shell.dart';
  import '../services/voucher_service.dart';

  class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
  }

  class _LoginScreenState extends State<LoginScreen> {
    final _usernameController = TextEditingController();
    final _passwordController = TextEditingController();
    final _authService = AuthService();
    final _passwordFocus = FocusNode();

    bool _isLoading = false;
    bool _obscure = true;
    String? _errorMessage;

    Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await _authService.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _passwordFocus.requestFocus();
      });
      return;
    }

    final admin = AuthService().isAdmin;

    // Admins get the dashboard: no cart, photo, or voucher prompt
    if (!admin) {
      await CartService().load();
      await AuthService().loadPhoto();
    }
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (admin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminShell()),
      );
      return;
    }

    VoucherService.promptPending = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

    @override
    void dispose() {
      _usernameController.dispose();
      _passwordController.dispose();
      _passwordFocus.dispose();
      super.dispose();
    }

    @override
  Widget build(BuildContext context) {
    return AuthShell(
      
      title: context.tr('Log In'),
      error: _errorMessage == null ? null : S.t(_errorMessage!),
      fields: [
        PillField(
          key: const ValueKey('username'),
          controller: _usernameController,
          label: context.tr('Username'),
        ),
        const SizedBox(height: 14),
        PillField(
          
          key: const ValueKey('password'),
          controller: _passwordController,
          focusNode: _passwordFocus,
          label: context.tr('Password'),
          obscure: _obscure,
          onSubmitted: (_) => _handleLogin(),
          suffix: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ],
      button: PillButton(
        text: context.tr('Login'),
        loading: _isLoading,
        onPressed: _isLoading ? null : _handleLogin,
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
                  Text('${context.tr("Don't have an account?")} ',
              style: const TextStyle(color: Colors.black54)),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SignupScreen()),
            ),
            child: Text(context.tr('Sign up here'),
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

