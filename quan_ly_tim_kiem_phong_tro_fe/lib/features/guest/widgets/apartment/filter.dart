import 'package:flutter/material.dart';

class Filter extends StatelessWidget {
  const Filter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 145.28,
          height: 42,
          padding: const EdgeInsets.only(
            top: 11,
            left: 37,
            right: 15,
            bottom: 11,
          ),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: const Color(0xFF4285F4),
              ),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 16.67,
                top: 12.17,
                child: Text(
                  'Filter',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 0.95,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
