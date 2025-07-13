import 'package:flutter/material.dart';

class ApartmentAmenities extends StatelessWidget {
  const ApartmentAmenities({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final amenities = [
      'Miễn phí wifi',
      'Có hồ bơi vô cực',
      'Có bãi đỗ xe',
      'Hỗ trợ trên 24/24',
    ];

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF4285F4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Các tiện nghi hàng đầu',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          ...amenities.map(
            (item) => Padding(
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.green, size: screenWidth * 0.05),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
