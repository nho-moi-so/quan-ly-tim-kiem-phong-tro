import 'package:flutter/material.dart';

class ApartmentMap extends StatelessWidget {
  const ApartmentMap({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
            'Vị Trí',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: screenWidth * 0.4,
                height: screenWidth * 0.3,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/map.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '9.2 Trên cả tuyệt vời',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Điểm đánh giá vị trí',
                      style: TextStyle(
                        fontSize: screenWidth * 0.036,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            color: const Color(0xFF4285F4),
                            size: screenWidth * 0.045),
                        SizedBox(width: screenWidth * 0.01),
                        Expanded(
                          child: Text(
                            '45 Nguyễn Văn Cừ, Cần Thơ',
                            style: TextStyle(
                              fontSize: screenWidth * 0.036,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
