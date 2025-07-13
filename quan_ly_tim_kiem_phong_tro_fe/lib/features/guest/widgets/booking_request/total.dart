import 'package:flutter/material.dart';

class Total extends StatelessWidget {
  const Total({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4285F4), width: 1),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng Tiền',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          buildPriceRow('Giá gốc (1 phòng x 1 đêm)', '4.500.000 đ', context),
          const SizedBox(height: 12),
          buildPriceRow('Giá của chúng tôi', '5.200.000 đ', context, isNormalColor: true),
          const SizedBox(height: 12),
          buildPriceRow('Coupon đã sử dụng', '-21%', context, isCoupon: true),
          const SizedBox(height: 12),
          buildPriceRow('Thuế và phi', '450.000 đ', context, isCoupon: true),
          const Divider(height: 32, thickness: 1),
          buildPriceRow('Giá tiền', '4.950.000 đ', context, isCoupon: true),
        ],
      ),
    );
  }

  Widget buildPriceRow(String label, String value, BuildContext context, {bool isCoupon = false, bool isNormalColor = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isCoupon
                ? const Color(0xFFFF0000)
                : isNormalColor
                    ? Colors.black
                    : const Color(0xFFF7210F),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
