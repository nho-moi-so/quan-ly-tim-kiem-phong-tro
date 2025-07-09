//done
import 'package:flutter/material.dart';

class CardRoomDetailWidget extends StatelessWidget {
  const CardRoomDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mã Phòng Mới',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withOpacity(0.8),
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.47,
              ),
            ),
            const SizedBox(height: 8),
            _buildInputBox(width: 363, height: 41),
            const SizedBox(height: 16),
            _buildLabeledInput('Diện Tích ', height: 41),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildLabeledInput('Checkin ', height: 41)),
                const SizedBox(width: 16),
                Expanded(child: _buildLabeledInput('Checkout ', height: 41)),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabeledInput('Sức Chứa Tối Đa ', height: 45),
            const SizedBox(height: 16),
            _buildLabeledInput('Trạng Thái Phòng', height: 41),
            const SizedBox(height: 16),
            _buildLabeledInput('Giá Phòng ', height: 37),
            const SizedBox(height: 16),
            _buildLabeledInput('Mô Tả Thêm', height: 64),
            const SizedBox(height: 16),
            _buildOptionRow('+ Thêm Tiện Ích'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildCheckboxOption('Cho Nuôi Chó Mèo'),
                _buildCheckboxOption('Có Khóa Vân Tay, Mật Khảu'),
                _buildCheckboxOption('Bãi Đậu Xe'),
                _buildCheckboxOption('Wifi miễn phí'),
              ],
            ),
            const SizedBox(height: 24),
            _buildOptionRow('+ Loại Phòng', width: 120),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              children: [
                _buildRadioOption('1 Phòng Ngủ'),
                _buildRadioOption('2 Phòng Ngủ'),
                _buildRadioOption('Studio'),
                _buildRadioOption('3 Phòng Ngủ'),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Upload Images',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            _buildImageUploadBox(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton('Hủy', color: Colors.white, textColor: Colors.black),
                _buildActionButton('Cập Nhật', color: const Color(0xFF4285F4), textColor: Colors.white, width: 153),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF4285F4)),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Widget _buildLabeledInput(String label, {required double height}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black.withOpacity(0.8),
            fontSize: 15,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.47,
          ),
        ),
        const SizedBox(height: 8),
        _buildInputBox(width: double.infinity, height: height),
      ],
    );
  }

  Widget _buildOptionRow(String text, {double width = 167}) {
    return Container(
      width: width,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xC19E4F4F),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Noto Sans',
          fontWeight: FontWeight.w400,
          height: 1.29,
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 17,
          height: 17,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFFD9D9D9),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.w400,
            height: 1.29,
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF4285F4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          const Icon(Icons.image_outlined, size: 48),
          const SizedBox(height: 8),
          const Text(
            'Drag and drop your images here, or click to browse',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 11.9,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.68,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Upload files',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 11.9,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.68,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, {required Color color, required Color textColor, double width = 74}) {
    return Container(
      width: width,
      height: 50.87,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
        border: color == Colors.white ? Border.all(color: const Color(0xFF4285F4)) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 19,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          height: 0.95,
        ),
      ),
    );
  }
}
