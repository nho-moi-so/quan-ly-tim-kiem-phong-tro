import 'package:flutter/material.dart';

import '../controller/auth_controller.dart';


class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authController = AuthController();
  
  String _selectedRole = 'guest'; // Mặc định là guest
  bool _acceptTerms = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    // Check terms acceptance
    if (!_acceptTerms) {
      _showErrorSnackBar('Bạn phải chấp nhận điều khoản để tiếp tục');
      return;
    }

    // Show loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Call controller
      final result = await _authController.registerUser(
        username: _usernameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        role: _selectedRole,
      );

      if (!mounted) return;

      if (result['success']) {
        // Show success message
        _showSuccessSnackBar(result['message']);
        
        // Wait a bit then navigate to login
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        
        // Navigate to login screen
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // Show error message
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      if (!mounted) return;
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
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
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
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAFBFF),
            Color(0xFFFFFFFF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE0E7FF),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Tạo tài khoản mới',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: 'Noto Sans',
              color: Color(0xFF1A1F36),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vui lòng điền thông tin để đăng ký',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Noto Sans',
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),

          // Username
          _buildLabel('Tên người dùng'),
          const SizedBox(height: 8),
          _buildInputField(
            'Nhập tên của bạn',
            _usernameController,
            Icons.person_outline,
          ),
          const SizedBox(height: 16),

          // Phone
          _buildLabel('Số điện thoại'),
          const SizedBox(height: 8),
          _buildInputField(
            'Nhập số điện thoại',
            _phoneController,
            Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Email
          _buildLabel('Email'),
          const SizedBox(height: 8),
          _buildInputField(
            'Nhập địa chỉ email',
            _emailController,
            Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Role Selection
          _buildLabel('Vai trò'),
          const SizedBox(height: 8),
          _buildRoleSelector(),
          const SizedBox(height: 16),

          // Password
          _buildLabel('Mật khẩu'),
          const SizedBox(height: 8),
          _buildInputField(
            'Nhập mật khẩu',
            _passwordController,
            Icons.lock_outline,
            isPassword: true,
            showPassword: _showPassword,
            onTogglePassword: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password
          _buildLabel('Xác nhận mật khẩu'),
          const SizedBox(height: 8),
          _buildInputField(
            'Nhập lại mật khẩu',
            _confirmPasswordController,
            Icons.lock_outline,
            isPassword: true,
            showPassword: _showConfirmPassword,
            onTogglePassword: () {
              setState(() {
                _showConfirmPassword = !_showConfirmPassword;
              });
            },
          ),
          const SizedBox(height: 20),

          // Terms checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _acceptTerms,
                  onChanged: (val) {
                    setState(() {
                      _acceptTerms = val ?? false;
                    });
                  },
                  activeColor: const Color(0xFF4C6FFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tôi đồng ý với điều khoản dịch vụ và chính sách bảo mật',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Noto Sans',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sign Up Button
          Container(
            width: double.infinity,
            height: 54,
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
                onTap: _isLoading ? null : _signUp,
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
                      : const Text(
                          'Đăng ký',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Noto Sans',
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'Noto Sans',
        color: Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildInputField(
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !showPassword,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w500,
        color: Color(0xFF1F2937),
      ),
      decoration: InputDecoration(
        hintText: hint,
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
          child: Icon(
            icon,
            color: const Color(0xFF4C6FFF),
            size: 20,
          ),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
                onPressed: onTogglePassword,
              )
            : null,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFCDE6), width: 2),
      ),
      child: Column(
        children: [
          _buildRoleOption(
            'guest',
            'Người thuê',
            'Tìm kiếm và thuê phòng trọ',
            Icons.person_search_rounded,
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: const Color(0xFFE0E7FF),
          ),
          _buildRoleOption(
            'owner',
            'Chủ căn hộ',
            'Đăng tin và quản lý phòng trọ',
            Icons.apartment_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedRole == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          const Color(0xFF4C6FFF).withOpacity(0.15),
                          const Color(0xFF4C6FFF).withOpacity(0.05),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          const Color(0xFF6B7280).withOpacity(0.1),
                          const Color(0xFF6B7280).withOpacity(0.05),
                        ],
                      ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF4C6FFF)
                    : const Color(0xFF6B7280),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Noto Sans',
                      color: isSelected
                          ? const Color(0xFF1F2937)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Noto Sans',
                      color: isSelected
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF4C6FFF), Color(0xFF6B8AFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4C6FFF)
                      : const Color(0xFFBFCDE6),
                  width: 2,
                ),
                color: isSelected ? null : Colors.transparent,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4C6FFF).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
