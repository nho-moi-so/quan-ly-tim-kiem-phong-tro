//done
import 'package:flutter/material.dart';

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 46,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: ShapeDecoration(
          color: const Color(0xFFEBE7E7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem('Tổng Quan'),
            _buildNavItem('Khu Trọ'),
            _buildNavItem('Room', isActive: true),
            _buildNavItem('Bài Đăng'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String title, {bool isActive = false}) {
    return Container(
      width: 74,
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      decoration: ShapeDecoration(
        color: isActive ? Colors.white : null,
        shape: RoundedRectangleBorder(
          side: isActive
              ? const BorderSide(
                  width: 1,
                  color: Color(0xFF4285F4),
                )
              : BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            height: 2.54,
          ),
        ),
      ),
    );
  }
}
