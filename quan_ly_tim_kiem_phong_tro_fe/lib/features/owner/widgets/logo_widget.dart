import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double scale;

  const LogoWidget({super.key, this.scale = 1}); // Mặc định scale = 1

  @override
  Widget build(BuildContext context) {
    final double widgetWidth = 209 * scale;
    final double imageSize = 160 * scale; // To hơn nữa

    return Container(
      width: widgetWidth,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dùng Align với heightFactor để "cắt" bớt không gian thừa bên dưới của ảnh trong layout
          Align(
            alignment: Alignment.topCenter,
            heightFactor: 95 / 160, // Chỉ lấy 95px chiều cao layout so với 160px thực tế
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8 * scale),
              child: Image.asset(
                "assets/logo_app.png",
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Không cần Transform.translate nữa, text sẽ nằm ngay dưới móng tòa nhà
          Column(
            children: [
              Text(
                'CONDOTEL',
                style: TextStyle(
                  color: const Color(0xFF1F2937),
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2 * scale,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2 * scale),
              Text(
                'SMART & MODERN',
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: 9 * scale,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2 * scale,
                ),
                textAlign: TextAlign.center,
              ),
              // Thêm khoảng trống bên dưới toàn bộ cục Logo+Chữ để cách xa phần tử bên dưới ("Chào Mừng Trở Lại")
              SizedBox(height: 24 * scale), 
            ],
          ),
        ],
      ),
    );
  }
}
