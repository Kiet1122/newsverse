import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../../../../routes/route_names.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Perform login with email and password
  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();

      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (success && mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          RouteNames.home, 
          (route) => false
        );
      }
    }
  }

  /// Navigate to registration screen
  void _navigateToRegister() {
    Navigator.pushReplacementNamed(context, RouteNames.register);
  }

  /// Navigate to forgot password screen
  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, RouteNames.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Header section with logo and welcome message
                _buildHeader(theme, colors),
                const SizedBox(height: 48),
                
                // Login form section
                _buildForm(theme, colors),
                const SizedBox(height: 24),
                
                // Action buttons section
                _buildActionSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header section with app logo and welcome text
  Widget _buildHeader(ThemeData theme, ColorScheme colors) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary.withOpacity(0.1),
                colors.primary.withOpacity(0.05),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.newspaper_rounded,
            size: 50,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Chào mừng trở lại',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Đăng nhập để tiếp tục khám phá tin tức',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the login form with email and password fields
  Widget _buildForm(ThemeData theme, ColorScheme colors) {
    return Column(
      children: [
        AuthTextField(
          controller: _emailController,
          labelText: 'Email',
          hintText: 'Nhập email của bạn',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(Icons.email_rounded, color: colors.onSurface.withOpacity(0.5)),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email không hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        AuthTextField(
          controller: _passwordController,
          labelText: 'Mật khẩu',
          hintText: 'Nhập mật khẩu của bạn',
          obscureText: _obscurePassword,
          prefixIcon: Icon(Icons.lock_rounded, color: colors.onSurface.withOpacity(0.5)),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: colors.onSurface.withOpacity(0.5),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mật khẩu';
            }
            if (value.length < 6) {
              return 'Mật khẩu phải có ít nhất 6 ký tự';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _navigateToForgotPassword,
            style: TextButton.styleFrom(
              foregroundColor: colors.primary,
            ),
            child: const Text('Quên mật khẩu?'),
          ),
        ),
      ],
    );
  }

  /// Builds the action section with login button and registration link
  Widget _buildActionSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorSnackBar(context, authProvider.error!);
            authProvider.clearError();
          });
        }

        return Column(
          children: [
            AuthButton(
              text: 'Đăng nhập',
              onPressed: () {
                if (!authProvider.isLoading) {
                  _login(context);
                }
              },
              isLoading: authProvider.isLoading,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chưa có tài khoản? ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                TextButton(
                  onPressed: authProvider.isLoading ? null : _navigateToRegister,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text(
                    'Đăng ký ngay',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Shows error message in a snackbar
  void _showErrorSnackBar(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(error)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}