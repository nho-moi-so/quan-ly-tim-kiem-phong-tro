import 'package:flutter/material.dart';

class LabelTitleWidget extends StatelessWidget {
  final String title;
  final String header;
  const LabelTitleWidget({super.key, required this.title, this.header = ''});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        if (header.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            header,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
