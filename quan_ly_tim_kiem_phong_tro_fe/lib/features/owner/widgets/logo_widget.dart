import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double scale;

  const LogoWidget({super.key, this.scale = 1}); // Mặc định scale = 1

  @override
  Widget build(BuildContext context) {
    // Chiều rộng lớn để chữ hiển thị rõ ràng
    final double imageWidth = 220 * scale;
    // Tăng lại chiều cao để không bị cắt mất phần đỉnh tòa nhà
    final double imageHeight = 115 * scale;

    return SafeArea(
      bottom: false,
      minimum: EdgeInsets.only(top: 10 * scale),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5 * scale),
        child: SizedBox(
          width: imageWidth,
          height: imageHeight,
          child: Image.asset(
            "assets/Rectangle.png",
            fit: BoxFit.cover,
            // Chỉnh lại tọa độ để vừa vặn cả đỉnh tòa nhà lẫn dòng chữ bên dưới
            alignment: const Alignment(0.0, 0.4), 
          ),
        ),
      ),
    );
  }
}
