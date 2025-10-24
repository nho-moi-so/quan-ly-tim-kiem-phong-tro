import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AuthSwitchText extends StatelessWidget {
  final bool isLogin; // true nếu đang ở màn hình Login
  final VoidCallback? onTap;

  const AuthSwitchText({
    super.key,
    required this.isLogin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text1 = isLogin ? "Don't have an account?" : "Already have an account?";
    final text2 = isLogin ? "Register" : "Log in";

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text1,
            style: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.25,
            ),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: text2,
            style: const TextStyle(
              color: Color(0xFF4285F4),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              height: 1.25,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bạn đã nhấn vào $text2')),
          );
          if (onTap != null) onTap!();
              },
          ),
        ],
      ),
    );
  }
}
