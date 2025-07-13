import 'package:flutter/material.dart';

class ApartmentBookingForm extends StatelessWidget {
  const ApartmentBookingForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'assets/images/1696583537720.png', 
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("MiniHouse Cần Thơ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
                    Row(
                      children: const [
                        Text(
                          '5.200.000đ',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '4.500.000đ',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 4),
                        Chip(
                          backgroundColor: Colors.redAccent,
                          label: Text('-21%',
                              style: TextStyle(color: Colors.white, fontSize: 12)),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "45 Nguyễn Văn Cừ, Cần Thơ",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Danh sách tiện nghi
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              InfoRow(text: "Miễn phí wifi"),
              InfoRow(text: "Có hồ bơi vô cực"),
              InfoRow(text: "Có bãi đỗ xe"),
              InfoRow(text: "Hỗ trợ trên 24/24"),
              InfoRow(text: "Hỗ trợ mang hành lý tận phòng"),
              InfoRow(text: "2 giường đơn"),
              InfoRow(text: "Đặt và thanh toán tiền ngay"),
              InfoRow(text: "Khuyến mãi chớp nhoáng"),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String text;
  const InfoRow({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
