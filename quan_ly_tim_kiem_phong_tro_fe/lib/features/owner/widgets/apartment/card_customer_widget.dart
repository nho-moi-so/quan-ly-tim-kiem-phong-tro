//done
import 'package:flutter/material.dart';

class CardCustomerWidget extends StatelessWidget {
  const CardCustomerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        return Center(
          child: Container(
            width: screenWidth * 0.9, // responsive width
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  // child: Text(
                  //   'Thêm Khách Thuê Mới',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     color: const Color(0xFF4B5563),
                  //     fontSize: 23,
                  //     fontFamily: 'Inter',
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                ),
                const SizedBox(height: 24),
                _buildLabel('Tên Khách Trọ'),
                _buildInputBox(),
                const SizedBox(height: 24),
                _buildLabel('Số Điện Thoại'),
                _buildInputBox(),
                const SizedBox(height: 24),
                _buildLabel('CCCD & Hộ Chiếu'),
                _buildInputBox(height: 80),
                const SizedBox(height: 24),
                _buildLabel('Giới Tính'),
                _buildInputBox(),
                const SizedBox(height: 24),
                _buildLabel('Địa Chỉ Thường Chú'),
                _buildInputBox(height: 63),
                const SizedBox(height: 32),
                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF4285F4), width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Thêm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black.withOpacity(0.8),
        fontSize: 15,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildInputBox({double height = 45}) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFF4285F4), width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}
