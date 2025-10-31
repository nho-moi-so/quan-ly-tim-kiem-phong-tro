import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/search_criteria.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/total.dart';
class ApartmentBookingForm extends StatelessWidget {
  final Apartment apartment;
  final SearchCriteria? criteria;

  const ApartmentBookingForm({
    super.key,
    required this.apartment,
    this.criteria,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Tính số ngày ở
    int soNgayO = 1; // mặc định 1 ngày
    if (criteria?.checkIn != null && criteria?.checkOut != null) {
      soNgayO = criteria!.checkOut!.difference(criteria!.checkIn!).inDays;
      if (soNgayO <= 0) soNgayO = 1;
    }

    // Tính tổng tiền
    double tongTien = (apartment.DailyRate ?? 0) * soNgayO;

    return SingleChildScrollView(
      child: Container(
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
                      Text(
                        apartment.Type ?? "Tên căn hộ",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          if (apartment.Deposit != null)
                            Text(
                              '${apartment.Deposit} đ',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            '${apartment.DailyRate ?? 0} đ',
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
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              apartment.address ?? "Địa chỉ",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
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
                  ? apartment.Requirements.map((r) => InfoRow(text: r)).toList()
                  : [const InfoRow(text: "Không có yêu cầu")],
            ),

            const SizedBox(height: 20),

            /// --- Phần bổ sung: Một số thông tin hữu ích khác ---
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
                  _infoRow(
                    Icons.add,
                    "Căn hộ gần trung tâm,\nhỗ trợ cho thuê xe di chuyển",
                  ),
                  const SizedBox(height: 8),
                  _infoRow(
                    Icons.apartment,
                    "Về căn hộ\nMột tòa nhà có 8 tầng\nMỗi tầng có 12 căn phòng\nGần trung tâm, có hồ bơi vô cực\nKèm nhiều tiện ích khác",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Hàm helper hiển thị info row
  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}

// Widget riêng để hiển thị mỗi requirement
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
