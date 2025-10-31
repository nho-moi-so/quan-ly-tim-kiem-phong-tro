import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';

class ApartmentAmenities extends StatelessWidget {
  final Apartment apartment;

  const ApartmentAmenities({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    final amenities = apartment.amenities ?? [
      'Miễn phí wifi',
      'Có hồ bơi vô cực',
      'Có bãi đỗ xe',
      'Hỗ trợ 24/24',
    ];

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Các tiện nghi hàng đầu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...amenities.map((item) => Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(item),
                ],
              )),
        ],
      ),
    );
  }
}
