import 'package:flutter/material.dart';

class FliterStatusWidget extends StatelessWidget {
  const FliterStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 394,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFEBE7E7),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0x3F000000),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Row(
        children: const [
          TabButton(label: 'Tất Cả', isActive: true),
          TabButton(label: 'Yêu Cầu Mới'),
          TabButton(label: 'Đã Thanh Toán'),
          SizedBox(width: 8),
          Text(
            'Đã Hủy',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 2.54,
            ),
          ),
        ],
      ),
    );
  }
}

class TabButton extends StatelessWidget {
  final String label;
  final bool isActive;

  const TabButton({super.key, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isActive
            ? Border.all(
                color: const Color(0xFF4285F4),
                width: 1,
              )
            : null,
      ),
      child: Center(
        child: Text(
          label,
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
