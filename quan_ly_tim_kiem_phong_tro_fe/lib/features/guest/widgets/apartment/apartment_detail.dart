import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
// chú ý: nhớ import file model Apartment của bạn

class ApartmentDetail extends StatelessWidget {
  final Apartment apartment;
  const ApartmentDetail({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final daily = apartment.DailyRate;
    final deposit = apartment.Deposit;

    final reqText =
        (apartment.Requirements != null && apartment.Requirements!.isNotEmpty)
        ? apartment.Requirements!.join(', ')
        : '-';

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              apartment.Type ?? 'Tên phòng',
              style: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),

            Text(
              daily != null ? formatVND(daily.toInt()) : '-',
              style: TextStyle(
                color: const Color(0xFFF7210F),
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: screenWidth * 0.03),

   
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: screenWidth * 0.045,
                  color: Colors.grey,
                ),
                SizedBox(width: screenWidth * 0.01),
                Expanded(
                  child: Text(
                    apartment.address ?? "Chưa có địa chỉ",
                    style: TextStyle(
                      color: const Color(0xFF4B5563),
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenWidth * 0.04),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InfoItem(
                  icon: Icons.bed,
                  text: "2 Giường",
                ),
                InfoItem(
                  icon: Icons.bathtub,
                  text: "1 Phòng Tắm",
                ),
                InfoItem(
                  icon: Icons.people,
                  text: "${apartment.maxOccupancy ?? 0} người", 
                ),
              ],
            ),

            SizedBox(height: screenWidth * 0.03),

            Text(
              "Đặt cọc: ${deposit != null ? formatVND(deposit.toInt()) : '-'}",
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: screenWidth * 0.02),

            buildRow(
              context,
              Icons.pets,
              'Yêu Cầu',
              reqText,
              TextStyle(fontWeight: FontWeight.w500),
              TextStyle(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    TextStyle labelStyle,
    TextStyle valueStyle,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
      child: Row(
        children: [
          Icon(icon, size: screenWidth * 0.04, color: const Color(0xFF4B5563)),
          SizedBox(width: screenWidth * 0.02),
          Text(label, style: labelStyle),
          SizedBox(width: screenWidth * 0.02),
          Expanded(child: Text(value, style: valueStyle)),
        ],
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

String formatVND(int value) {
  return "${value.toString()} ₫";
}
