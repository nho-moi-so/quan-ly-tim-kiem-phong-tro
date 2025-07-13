import 'package:flutter/material.dart';


class ApartmentAddress extends StatelessWidget {
  const ApartmentAddress({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = screenWidth * 0.2;

    return Container(
      width: screenWidth,
      height: headerHeight,
      decoration: BoxDecoration(color: const Color(0xFF4285F4)),
      child: Stack(
        children: [
          Positioned(
            right: 16,
            top: 43,
            child: Icon(Icons.favorite_border, size: 24, color: Colors.white),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Opacity(
                    opacity: 0.6,
                    child: Text(
                      '12:30',
                      style: TextStyle(
                        color: const Color(0xFF1C1B1F),
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.signal_cellular_alt, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Icon(Icons.wifi, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Icon(Icons.battery_full, size: 16, color: Colors.white),
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 43,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(7),
              ),
              padding: EdgeInsets.all(8),
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Positioned(
            left: 72,
            top: 46,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white.withOpacity(0.3),
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
          Positioned(
            left: 21,
            bottom: 40,
            child: Row(
              children: [
                Text(
                  'Cần Thơ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '(332)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 21,
            bottom: 16,
            child: Text(
              'T3, 8 TH7 - T5, 15TH7  ( 4 khách)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
