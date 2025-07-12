//done
import 'package:flutter/material.dart';

class LabelStatusWidget extends StatelessWidget {
  const LabelStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF1D1B1B)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _StatusItem(color: Color(0xFF34A853), label: 'Đang ở'),
          _StatusItem(color: Color(0xFFE64646), label: 'Đang Trống'),
          _StatusItem(color: Color(0xFFFBBC05), label: 'Đã Cọc Tiền'),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final Color color;
  final String label;

  const _StatusItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 17,
          height: 17,
          decoration: ShapeDecoration(
            color: color,
            shape: const OvalBorder(),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.w400,
            height: 1.12,
          ),
        ),
      ],
    );
  }
}
