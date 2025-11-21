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
    // Clear error khi screen được khởi tạo
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

  Future<void> _register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();

      print('📝 Thông tin đăng ký:');
      print('👤 Name: ${_nameController.text}');
      print('📧 Email: ${_emailController.text}');
      print('🔑 Password: ${_passwordController.text}');
      print('🎭 Role: $_selectedRole');

      final success = await authProvider.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
      );

      print('🎯 Kết quả đăng ký: $success');
      
      if (success && mounted) {
        print('✅ Đăng ký thành công, chuyển hướng đến Home...');
        // Đăng ký thành công, chuyển đến home
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, RouteNames.home);
      } else {
        print('❌ Đăng ký thất bại: ${authProvider.error}');
        // Error sẽ được hiển thị tự động qua Consumer
      }
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, RouteNames.login);
  }

  // Thêm các method để fix lỗi type
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Đăng ký',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tạo tài khoản mới để bắt đầu sử dụng ứng dụng.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 40),
                AuthTextField(
                  controller: _nameController,
                  labelText: 'Họ và tên',
                  hintText: 'Nhập họ và tên của bạn',
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Vai trò',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'user',
                      child: Text('Người dùng'),
                    ),
                    DropdownMenuItem(
                      value: 'journalist',
                      child: Text('Nhà báo'),
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
                const SizedBox(height: 20),
                AuthTextField(
                  controller: _passwordController,
                  labelText: 'Mật khẩu',
                  hintText: 'Nhập mật khẩu của bạn',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: _togglePasswordVisibility, // Sửa thành method
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: _toggleConfirmPasswordVisibility, // Sửa thành method
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
                const SizedBox(height: 32),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    // Hiển thị error message nếu có
                    if (authProvider.error != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              authProvider.error!,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 5),
                          ),
                        );
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
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Đã có tài khoản? ',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            TextButton(
                              onPressed: authProvider.isLoading ? null : _navigateToLogin,
                              child: const Text('Đăng nhập ngay'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}