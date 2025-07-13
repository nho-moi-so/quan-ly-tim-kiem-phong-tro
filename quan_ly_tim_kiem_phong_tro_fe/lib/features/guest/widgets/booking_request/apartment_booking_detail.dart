import 'package:flutter/material.dart';

class ApartmentBookingDetail extends StatelessWidget {
  const ApartmentBookingDetail({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        // Phần 1: Một số thông tin hữu ích khác
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Một số thông tin hữu ích khác",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _infoRow(Icons.check, "Nhận phòng - 14h\nTrả phòng - 12h"),
              const SizedBox(height: 8),
              _infoRow(Icons.add, "Căn hộ gần trung tâm,\nhỗ trợ cho thuê xe di chuyển"),
              const SizedBox(height: 8),
              _infoRow(Icons.apartment, "Về căn hộ\nMột tòa nhà có 8 tầng\nMỗi tầng có 12 căn phòng\nGần trung tâm, có hồ bơi vô cực\nKèm nhiều tiện ích khác"),
            ],
          ),
        ),

      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
