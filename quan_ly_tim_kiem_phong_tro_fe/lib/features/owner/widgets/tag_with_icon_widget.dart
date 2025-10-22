//done
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TagWithIconWidget extends StatelessWidget {
  // Constructor
  final String title;
  const TagWithIconWidget({super.key, required this.title});
  // const TagWithIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 214,
      height: 34,
      child: Row(
        children: [
          // Icon trái (SVG)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: SizedBox(
              width: 21,
              height: 24,
              child: SvgPicture.asset(
          'assets/frame_bagach.svg',
          fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Nút có border-radius
          Container(
            width: 183,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              children: [
              // Sử dụng file "Home filled.svg" thay cho Placeholder
              SizedBox(
                width: 18,
                height: 18,
                child: SvgPicture.asset(
                'assets/Home filled.svg',
                fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                  title,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
