import 'package:flutter/material.dart';

class LabelTitleAndQuayLaiWidget extends StatelessWidget {
  final String title;
  const LabelTitleAndQuayLaiWidget({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 309,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 26,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 23,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}