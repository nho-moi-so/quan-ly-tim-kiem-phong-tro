import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double scale;

  const LogoWidget({super.key, this.scale = 1}); // Mặc định scale = 1

  @override
  Widget build(BuildContext context) {
    final double imageSize = 103 * scale;
    final double textFontSize = 16 * scale;
    final double widgetWidth = 209 * scale;
    final double widgetHeight = (imageSize + 15) * scale;

    return SizedBox(
      width: widgetWidth,
      height: widgetHeight,
      child: Stack(
        children: [
          // Ảnh hình chữ nhật
          Positioned(
            left: 38 * scale,
            top: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8 * scale),
              child: Image.asset(
                "assets/Rectangle.png",
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dòng chữ bên dưới
          Positioned(
            left: 0,
            top: imageSize - 14 * scale,
            child: SizedBox(
              width: widgetWidth,
              child: Text(
                'Smart rentals, simple living.',
                style: TextStyle(
                  color: const Color(0xFF1C421B),
                  fontSize: textFontSize,
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
