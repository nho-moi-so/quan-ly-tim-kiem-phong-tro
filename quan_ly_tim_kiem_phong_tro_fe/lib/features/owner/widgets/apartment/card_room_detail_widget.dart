import 'package:flutter/material.dart';

class CardRoomDetailWidget extends StatelessWidget {
  const CardRoomDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Mã Phòng Mới'),
          _inputBox(),

          const SizedBox(height: 16),
          _label('Diện Tích'),
          _inputBox(),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Checkin'),
                    _inputBox(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Checkout'),
                    _inputBox(),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          _label('Sức Chứa Tối Đa'),
          _inputBox(),

          const SizedBox(height: 16),
          _label('Giá Phòng'),
          _inputBox(),

          const SizedBox(height: 16),
          _label('Mô Tả Thêm'),
          _inputBox(height: 64),

          const SizedBox(height: 16),
          _label('Trạng Thái Phòng'),
          _inputBox(height: 41),

          const SizedBox(height: 24),
          _label('+ Thêm Tiện Ích'),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: [
              _checkboxItem('Cho Nuôi Chó Mèo'),
              _checkboxItem('Bãi Đậu Xe'),
              _checkboxItem('Có Khóa Vân Tay, Mật Khẩu'),
              _checkboxItem('Wifi miễn phí'),
            ],
          ),

          const SizedBox(height: 24),
          _label('+ Loại Phòng'),
          Wrap(
            spacing: 20,
            children: [
              _radioItem('1 Phòng Ngủ'),
              _radioItem('2 Phòng Ngủ'),
              _radioItem('3 Phòng Ngủ'),
              _radioItem('Studio'),
            ],
          ),

          const SizedBox(height: 24),
          _label('Upload Images'),
          _uploadBox(),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton('Hủy', color: Colors.white, textColor: Colors.black),
              _actionButton('Cập Nhật', color: const Color(0xFF4285F4), textColor: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
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

  Widget _inputBox({double height = 41}) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF4285F4)),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Widget _checkboxItem(String label) {
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
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Noto Sans',
          ),
        ),
      ],
    );
  }

  Widget _radioItem(String label) {
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
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Noto Sans',
          ),
        ),
      ],
    );
  }

  Widget _uploadBox() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4285F4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            'Describe the property',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF808080),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Drag and drop your images here, or click to browse',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.9,
              fontFamily: 'Inter',
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: const Text(
              'Upload files',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w500,
                fontSize: 11.9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, {required Color color, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: const Color(0xFF4285F4)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 19,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
