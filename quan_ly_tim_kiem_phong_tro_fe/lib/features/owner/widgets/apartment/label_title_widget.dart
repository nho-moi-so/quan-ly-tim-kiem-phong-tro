import 'package:flutter/material.dart';

class LabelTitleWidget extends StatelessWidget {
  final String title;
  final String header;
  const LabelTitleWidget({super.key, required this.title, this.header = ''});

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
            title,
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
            header,
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
