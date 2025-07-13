import 'package:flutter/material.dart';

class ApartmentDetailContact extends StatelessWidget {
  const ApartmentDetailContact({super.key});

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

        // Phần 2: Liên hệ chủ nhà
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage("assets/images/avt7.png"),
                    radius: 25,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Em Bông", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("090 2343 2345"),
                      Text("Property Agent", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone, color: Colors.black),
                  label: const Text("Gọi Điện", style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0E0E0),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text("Liên Hệ Chủ Nhà"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: const Text("Đặt Phòng"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                  ),
                ),
              ),
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
