import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/booking_detail_dialog.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.035;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Cột trái
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow(Icons.home, "Mã Đơn:", fontSize),
                    _buildRow(Icons.person, "Tên Khách:", fontSize),
                    _buildRow(
                      Icons.calendar_today,
                      "Checkin- Checkout:",
                      fontSize,
                    ),
                    _buildRow(Icons.circle, "Trạng Thái:", fontSize),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 100,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              // Cột phải
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildValue("#023133", fontSize),
                    _buildValue("Mỹ Ngọc", fontSize),
                    _buildValue("12/05 - 14/05", fontSize),
                    _buildValue(
                      "Đã Thanh Toán",
                      fontSize,
                      statusColor: Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Xóa"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const BookingDetailDialog(),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Xem"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: fontSize, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: fontSize)),
          ),
        ],
      ),
    );
  }

  Widget _buildValue(String value, double fontSize, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (statusColor != null)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
