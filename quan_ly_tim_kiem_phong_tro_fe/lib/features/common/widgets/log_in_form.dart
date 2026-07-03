import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/main_screen.dart';

import '../controller/auth_controller.dart';

class LogInForm extends StatefulWidget {
  const LogInForm({super.key});

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = AuthController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authController.loginUser(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result['success']) {
        final role = result['role'] as String?;
        debugPrint('Đăng nhập thành công! Role: $role');
        debugPrint('User data: ${result['userData']}');

        // Show success message
        _showSuccessSnackBar(result['message']);

        // Navigate based on role
        if (role?.toLowerCase() == 'owner') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OwnerMainScreen()),
          );
        } 
        // else if (role?.toLowerCase() == 'guest') {
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (_) => const GuestMainScreen()),
        //   );
        // }
        else {
          _showErrorSnackBar('Vai trò người dùng không hợp lệ');
        }
      } else {
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Login error: $e');
      _showErrorSnackBar('Có lỗi xảy ra. Vui lòng thử lại.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email Field
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Noto Sans',
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: 'Nhập địa chỉ email của bạn',
            hintStyle: const TextStyle(
              fontSize: 14,
              fontFamily: 'Noto Sans',
              color: Color(0xFF9CA3AF),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4C6FFF).withOpacity(0.15),
                    const Color(0xFF4C6FFF).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.email_outlined,
                color: Color(0xFF4C6FFF),
                size: 20,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBFCDE6), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBFCDE6), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4C6FFF), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),

        const SizedBox(height: 16),

        // Password Field
        const Text(
          'Mật khẩu',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Noto Sans',
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: 'Nhập mật khẩu của bạn',
            hintStyle: const TextStyle(
              fontSize: 14,
              fontFamily: 'Noto Sans',
              color: Color(0xFF9CA3AF),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4C6FFF).withOpacity(0.15),
                    const Color(0xFF4C6FFF).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF4C6FFF),
                size: 20,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBFCDE6), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBFCDE6), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4C6FFF), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: const Color(0xFF6B7280),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),

        // const SizedBox(height: 8),

        // // Forgot Password
        // Align(
        //   alignment: Alignment.centerRight,
        //   child: TextButton(
        //     onPressed: () {
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(content: Text('Chức năng quên mật khẩu')),
        //       );
        //     },
        //     child: const Text(
        //       'Quên mật khẩu?',
        //       style: TextStyle(
        //         fontSize: 13,
        //         fontWeight: FontWeight.w600,
        //         fontFamily: 'Noto Sans',
        //         color: Color(0xFF4C6FFF),
        //       ),
        //     ),
        //   ),
        // ),

        const SizedBox(height: 16),

        // Login Button
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: _isLoading
                ? null
                : const LinearGradient(
                    colors: [Color(0xFF4C6FFF), Color(0xFF6B8AFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: _isLoading ? const Color(0xFF9CA3AF) : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isLoading
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF4C6FFF).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _handleLogin,
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.login_rounded, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Đăng Nhập',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Noto Sans',
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
