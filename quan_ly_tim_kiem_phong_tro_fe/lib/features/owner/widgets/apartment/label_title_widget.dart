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
      padding: const EdgeInsets.fromLTRB(1, 0, 1, 4), // Giảm padding bottom
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
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            header,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
