import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../../../../routes/route_names.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'user';

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Register a new user account
  Future<void> _register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();

      final success = await authProvider.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
      );
      
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, RouteNames.home);
      }
    }
  }

  /// Navigate to login screen
  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, RouteNames.login);
  }

  /// Toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  /// Toggle confirm password visibility
  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
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
                const SizedBox(height: 20),
                
                // Header section with icon and title
                _buildHeader(theme, colors),
                const SizedBox(height: 40),
                
                // Registration form section
                _buildForm(theme, colors),
                const SizedBox(height: 32),
                
                // Action buttons section
                _buildActionSection(),
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_add_rounded,
            size: 40,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Tạo tài khoản mới',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Điền thông tin để bắt đầu khám phá',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// Builds the registration form with all input fields
  Widget _buildForm(ThemeData theme, ColorScheme colors) {
    return Column(
      children: [
        AuthTextField(
          controller: _nameController,
          labelText: 'Họ và tên',
          hintText: 'Nhập họ và tên của bạn',
          prefixIcon: Icon(Icons.person_rounded, color: colors.onSurface.withOpacity(0.5)),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập họ và tên';
            }
            if (value.length < 2) {
              return 'Họ và tên phải có ít nhất 2 ký tự';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
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
        // Role selection dropdown
        _buildRoleDropdown(theme, colors),
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
            onPressed: _togglePasswordVisibility,
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
        const SizedBox(height: 20),
        AuthTextField(
          controller: _confirmPasswordController,
          labelText: 'Xác nhận mật khẩu',
          hintText: 'Nhập lại mật khẩu của bạn',
          obscureText: _obscureConfirmPassword,
          prefixIcon: Icon(Icons.lock_outline_rounded, color: colors.onSurface.withOpacity(0.5)),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: colors.onSurface.withOpacity(0.5),
            ),
            onPressed: _toggleConfirmPasswordVisibility,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng xác nhận mật khẩu';
            }
            if (value != _passwordController.text) {
              return 'Mật khẩu xác nhận không khớp';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Builds the role selection dropdown
  Widget _buildRoleDropdown(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vai trò',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colors.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outline.withOpacity(0.3)),
            color: colors.surface,
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: [
              DropdownMenuItem(
                value: 'user',
                child: Row(
                  children: [
                    Icon(Icons.person_rounded, size: 18, color: colors.onSurface.withOpacity(0.7)),
                    const SizedBox(width: 8),
                    const Text('Người dùng'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'journalist',
                child: Row(
                  children: [
                    Icon(Icons.article_rounded, size: 18, color: colors.onSurface.withOpacity(0.7)),
                    const SizedBox(width: 8),
                    const Text('Nhà báo'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedRole = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  /// Builds the action section with register button and login link
  Widget _buildActionSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorSnackBar(context, authProvider.error!);
          });
        }

        return Column(
          children: [
            AuthButton(
              text: 'Đăng ký',
              onPressed: () {
                if (!authProvider.isLoading) {
                  _register(context);
                }
              },
              isLoading: authProvider.isLoading,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Đã có tài khoản? ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                TextButton(
                  onPressed: authProvider.isLoading ? null : _navigateToLogin,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text(
                    'Đăng nhập ngay',
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