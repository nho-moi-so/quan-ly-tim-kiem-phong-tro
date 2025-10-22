import 'package:flutter/material.dart';

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
  bool _acceptTerms = false;
  bool _showPassword = false;

  void _signUp() {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must accept the terms to continue.')),
      );
      return;
    }

    final message = '''
Username: ${_usernameController.text}
Phone: ${_phoneController.text}
Email: ${_emailController.text}
Password: ${_passwordController.text}
Confirm: ${_confirmPasswordController.text}
Terms accepted: $_acceptTerms
''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 353,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField('Your username', _usernameController),
          const SizedBox(height: 16),
          _buildInputField('Your phone', _phoneController),
          const SizedBox(height: 16),
          _buildInputField('Email Address', _emailController),
          const SizedBox(height: 16),
          _buildInputField('Password', _passwordController, isPassword: true),
          const SizedBox(height: 16),
          _buildInputField('Confirm password', _confirmPasswordController, isPassword: true),
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (val) {
                  setState(() {
                    _acceptTerms = val ?? false;
                  });
                },
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'I accept the terms and privacy policy',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _signUp,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: ShapeDecoration(
                color: const Color(0xFF4285F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller, {bool isPassword = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFF4285F4)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_showPassword,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
