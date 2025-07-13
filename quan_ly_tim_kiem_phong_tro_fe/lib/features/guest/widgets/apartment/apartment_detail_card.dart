import 'package:flutter/material.dart';

class ApartmentDetailCard extends StatelessWidget {
  const ApartmentDetailCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double padding = screenWidth * 0.04;

    TextStyle labelStyle = TextStyle(
      color: const Color(0xFF4B5563),
      fontSize: screenWidth * 0.04,
      fontWeight: FontWeight.w400,
    );
    TextStyle valueStyle = TextStyle(
      color: Colors.black,
      fontSize: screenWidth * 0.045,
      fontWeight: FontWeight.w500,
    );

    return Container(
      margin: EdgeInsets.all(padding),
      padding: EdgeInsets.symmetric(vertical: padding),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        border: Border.all(color: const Color(0xFF4285F4), width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Chi tiết MiniHouse',
              style: TextStyle(
                color: Colors.black.withOpacity(0.71),
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: padding),
          buildRow(context, Icons.confirmation_number, 'Mã Phòng', '1', labelStyle, valueStyle),
          buildRow(context, Icons.bed, 'Giường', '1', labelStyle, valueStyle),
          buildRow(context, Icons.group, 'Số người', '2', labelStyle, valueStyle),
          buildRow(context, Icons.pets, 'Yêu Cầu', 'Không mang thú cưng', labelStyle, valueStyle),
          buildRow(context, Icons.meeting_room, 'Tên Phòng', 'Phòng 002-KV1', labelStyle, valueStyle),
          buildRow(context, Icons.bathtub, 'Phòng Tắm', 'Có', labelStyle, valueStyle),
        ],
      ),
    );
  }

  Widget buildRow(BuildContext context, IconData icon, String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF4285F4), size: 24),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: labelStyle)),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}
