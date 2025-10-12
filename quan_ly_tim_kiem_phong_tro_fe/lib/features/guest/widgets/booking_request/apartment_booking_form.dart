import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';

class ApartmentBookingForm extends StatelessWidget {
  final Apartment apartment;

  const ApartmentBookingForm({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
          /// --- Hình + tiêu đề ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(
                      (apartment.PathImage.isNotEmpty)
                          ? apartment.PathImage.first
                          : "https://via.placeholder.com/100x80.png?text=No+Image",
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
                    Text(apartment.Type ?? "Tên căn hộ",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
                    Row(
                      children: [
                        if (apartment.Deposit != null)
                          Text(
                            '${apartment.Deposit}đ',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          '${apartment.DailyRate ?? 0}đ',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            apartment.address ?? "Địa chỉ",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
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

          /// --- Tiện ích (Requirements) ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (apartment.Requirements.isNotEmpty)
                ? apartment.Requirements
                    .map((r) => InfoRow(text: r))
                    .toList()
                : [const InfoRow(text: "Không có yêu cầu")],
          ),

          const SizedBox(height: 12),

          /// --- Mật khẩu phòng ---
          Row(
            children: [
              const Text("Mật khẩu nhận phòng: ",
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text(apartment.password ?? "---",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
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
