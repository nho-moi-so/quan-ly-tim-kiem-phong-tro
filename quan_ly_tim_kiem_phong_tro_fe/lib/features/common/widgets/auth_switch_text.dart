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
    final text1 = isLogin ? "Chưa có tài khoản?" : "Đã có tài khoản?";
    final text2 = isLogin ? "Đăng ký ngay" : "Đăng nhập";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: text1,
              style: const TextStyle(
                color: Color(0xFF6B7280),
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
                color: Color(0xFF4C6FFF),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF4C6FFF),
                height: 1.25,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Chuyển đến trang $text2'),
                  ],
                ),
                backgroundColor: const Color(0xFF4C6FFF),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            if (onTap != null) onTap!();
                },
            ),
          ],
        ),
      ),
    );
  }
}
