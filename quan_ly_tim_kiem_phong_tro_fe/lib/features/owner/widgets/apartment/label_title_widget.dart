import 'package:flutter/material.dart';

class LabelTitleWidget extends StatelessWidget {
  const LabelTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Chung Cư Nam Long',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w300,
              height: 0.9,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            '50, Trịnh Hoài Đức, Phường Vĩnh Thanh Vân TP. Rạch Giá',
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w300,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
