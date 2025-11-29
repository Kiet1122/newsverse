import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../../../../routes/route_names.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

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
    super.dispose();
  }

  /// Send password reset email to the provided email address
  Future<void> _resetPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();

      final success = await authProvider.resetPassword(
        _emailController.text.trim(),
      );

      if (success && mounted) {
        setState(() {
          _isEmailSent = true;
        });
      }
    }
  }

  /// Navigate back to login screen
  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, RouteNames.login);
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
                
                // Header section with icon and title
                _buildHeader(theme, colors),
                const SizedBox(height: 40),
                
                // Main content section
                _buildContent(theme, colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header section with icon and title
  Widget _buildHeader(ThemeData theme, ColorScheme colors) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            size: 40,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Khôi phục mật khẩu',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }

  /// Builds the main content based on email sent status
  Widget _buildContent(ThemeData theme, ColorScheme colors) {
    if (_isEmailSent) {
      return _buildSuccessState(theme, colors);
    }

    return _buildFormState(theme, colors);
  }

  /// Builds the form state for entering email address
  Widget _buildFormState(ThemeData theme, ColorScheme colors) {
    return Column(
      children: [
        Text(
          'Nhập email của bạn để nhận liên kết khôi phục mật khẩu',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
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
        const SizedBox(height: 32),
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showErrorSnackBar(context, authProvider.error!);
                authProvider.clearError();
              });
            }

            return AuthButton(
              text: 'Gửi liên kết khôi phục',
              onPressed: () {
                if (authProvider.isLoading) return;
                _resetPassword(context);
              },
              isLoading: authProvider.isLoading,
            );
          },
        ),
      ],
    );
  }

  /// Builds the success state after email has been sent
  Widget _buildSuccessState(ThemeData theme, ColorScheme colors) {
    return Column(
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 80,
          color: colors.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Đã gửi email thành công',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Chúng tôi đã gửi hướng dẫn khôi phục mật khẩu đến email của bạn. Vui lòng kiểm tra hộp thư và làm theo hướng dẫn.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        AuthButton(
          text: 'Quay lại đăng nhập',
          onPressed: _navigateToLogin,
        ),
      ],
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