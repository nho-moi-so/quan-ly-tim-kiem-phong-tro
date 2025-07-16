import 'package:flutter/material.dart';

class RoomDetailCardWidget extends StatelessWidget {
  const RoomDetailCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: 378,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xD8756A6A),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _infoField(label: 'Phòng', value: '403'),
                    const SizedBox(width: 12),
                    _infoField(label: 'Khu', value: 'Tầng 4'),
                  ],
                ),
                const SizedBox(height: 12),
                _infoField(label: 'Diện Tích', value: '30m2', fullWidth: true),
                const SizedBox(height: 12),
                _infoField(label: 'Tiền Phòng', value: '1.500.000', fullWidth: true),
                const SizedBox(height: 12),
                _infoField(
                  label: 'Địa Chỉ',
                  value: 'Chung cư nam long, hưng thạnh, cái răng',
                  fullWidth: true,
                ),
                const SizedBox(height: 12),
                _infoField(
                  label: 'Mô Tả',
                  value:
                      'Phòng dành cho 4 người, có 2 phòng ngủ và 1 phòng khách, có phòng bếp và 3 wc',
                  fullWidth: true,
                  multiline: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upload Images',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 157,
                    height: 118,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: NetworkImage("https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/1200px-Image_created_with_a_mobile_phone.png"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0x354285F4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Hủy', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Cập Nhật'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoField({
    required String label,
    required String value,
    bool fullWidth = false,
    bool multiline = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.6),
            fontSize: 14,
            fontFamily: 'Noto Sans',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: fullWidth ? double.infinity : 166,
          height: multiline ? 94 : 41,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF4285F4)),
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Noto Sans',
            ),
          ),
        ),
      ],
    );
  }
}
