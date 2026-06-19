import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/format_datetime.dart';

class ExtendInfoWidget extends StatelessWidget {
  final String checkInTime;
  final String checkOutTime;
  final String extraInfo;
  final String description;

  const ExtendInfoWidget({
    super.key,
    required this.checkInTime,
    required this.checkOutTime,
    required this.extraInfo,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF4285F4), width: 1),
        borderRadius: BorderRadius.circular(7),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          const Text(
            "Một số thông tin hữu ích khác",
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          // Nhận phòng - Trả phòng
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.check_box, color: Color(0xFF4285F4), size: 28),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const Text(
                    //   "Nhận phòng - Trả phòng",
                    //   style: TextStyle(
                    //     fontSize: 15,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: "Nhận phòng - "),
                          TextSpan(
                            text: formatDateTime(DateTime.parse(checkInTime)),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: "\nTrả phòng - "),
                          TextSpan(
                            text: formatDateTime(DateTime.parse(checkOutTime)),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Extra info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.card_giftcard, color: Color(0xFF4285F4), size: 28),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  extraInfo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Description
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.apartment, color: Color(0xFF4285F4), size: 28),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
