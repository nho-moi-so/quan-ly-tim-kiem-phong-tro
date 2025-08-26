import 'package:flutter/material.dart';

class ApartmentAddress extends StatelessWidget {
  final String address;
  final String dateRange;
  final int guestCount;
  final int resultCount;
  const ApartmentAddress({
    super.key,
    required this.address,
    required this.dateRange,
    required this.guestCount,
    required this.resultCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF4285F4), // ✅ nền xanh
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.notifications, color: Colors.white),
                  SizedBox(width: 12),
                  Icon(Icons.shopping_cart, color: Colors.white),
                ],
              ),
              Icon(Icons.menu, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                address.isNotEmpty ? address : "Chưa có địa chỉ",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "($resultCount)", // số kết quả
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            "$dateRange  (${guestCount} khách)",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}