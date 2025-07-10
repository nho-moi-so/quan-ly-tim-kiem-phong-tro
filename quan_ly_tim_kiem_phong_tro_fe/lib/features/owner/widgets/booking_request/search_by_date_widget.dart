import 'package:flutter/material.dart';

class SearchByDateWidget extends StatelessWidget {
  const SearchByDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 383,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ngày Đặt',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Lịch Đặt Phòng',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Noto Sans',
                    fontWeight: FontWeight.w400,
                    height: 1.29,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),

          // From and To Dates
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Từ Ngày',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildDateBox(),
                ],
              ),
              const SizedBox(width: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đến',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildDateBox(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox() {
    return Container(
      width: 96,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF4285F4), width: 1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: const Text(
        '--/--/----', // bạn có thể thay bằng date picker sau
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}
