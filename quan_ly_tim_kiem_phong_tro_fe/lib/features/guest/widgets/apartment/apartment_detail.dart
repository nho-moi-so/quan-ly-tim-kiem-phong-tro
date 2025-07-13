import 'package:flutter/material.dart';

class ApartmentDetail extends StatelessWidget {
  const ApartmentDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MiniHouse Cần Thơ',
              style: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '5.200.000đ',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.65),
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  '4.500.000đ',
                  style: TextStyle(
                    color: const Color(0xFFF7210F),
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenWidth * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-21%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.03),
            Row(
              children: [
                Icon(Icons.location_on, size: screenWidth * 0.045, color: Colors.grey),
                SizedBox(width: screenWidth * 0.01),
                Expanded(
                  child: Text(
                    '45 Nguyễn Văn Cừ, Cần Thơ',
                    style: TextStyle(
                      color: const Color(0xFF4B5563),
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.03),
            // Rating and info row
            Row(
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(Icons.star, color: Colors.amber, size: screenWidth * 0.04),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  '9.2 Trên cả tuyệt vời',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  '126 nhận xét',
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.04),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                InfoItem(icon: Icons.bed, text: '1 Giường'),
                InfoItem(icon: Icons.bathtub, text: '1 Phòng Tắm'),
                InfoItem(icon: Icons.people, text: '2 người'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4B5563), size: screenWidth * 0.04),
        SizedBox(width: screenWidth * 0.01),
        Text(
          text,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            color: const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}
