import 'package:flutter/material.dart';

class LabelTitleAndQuayLaiWidget extends StatelessWidget {
  const LabelTitleAndQuayLaiWidget({super.key});

  @override
  Widget build(BuildContext context) {
  return SizedBox(
    width: 309,
    height: 30,
    child: Stack(
      children: [
      Positioned(
        left: 0,
        top: 0,
        child: IconButton(
        icon: const Icon(Icons.arrow_back),
        iconSize: 26,
        onPressed: () {
          Navigator.of(context).pop();
        },
        ),
      ),
      const Positioned(
          left: 75,
          top: 8,
          child: SizedBox(
            width: 234,
            height: 19,
            child: Text(
              'Thêm Phòng Mới',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 23,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 0.96,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

}