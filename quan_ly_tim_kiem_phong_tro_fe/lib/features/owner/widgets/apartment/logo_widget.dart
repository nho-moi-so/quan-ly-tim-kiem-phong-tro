import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 209,
      height: 118,
      child: Stack(
        children: [
          // Ảnh hình tròn
          Positioned(
            left: 38,
            top: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                "assets/Rectangle.png",
                width: 103,
                height: 103,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dòng chữ bên dưới
          Positioned(
            left: 0,
            top: 89,
            child: SizedBox(
              width: 209,
              child: Text(
                'Smart rentals, simple living.',
                style: TextStyle(
                  color: const Color(0xFF1C421B),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w200,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
