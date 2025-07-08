//done
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 355,
      height: 490,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFBFBFBF),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 355,
                height: 200,
                decoration: ShapeDecoration(
                  image: const DecorationImage(
                    image: NetworkImage("https://placehold.co/355x200"),
                    fit: BoxFit.cover,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
              ),
              Container(
                width: 355,
                height: 200,
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(0.5, 0),
                    end: Alignment(0.5, 1),
                    colors: [Color(0x00D9D9D9), Colors.black, Colors.black],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
              ),
              Positioned(
                left: 178,
                top: 185,
                child: Row(
                  children: List.generate(5, (index) {
                    double size = 6 - index * 0.5;
                    return Container(
                      width: size,
                      height: size,
                      margin: const EdgeInsets.symmetric(horizontal: 1.25),
                      decoration: ShapeDecoration(
                        color: index == 0 ? const Color(0xFFF2F2F2) : const Color(0xFFBFBFBF),
                        shape: const OvalBorder(),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabelValue('Giá thuê:', '2.500.000đ/tháng'),
                    _buildLabelValue('Diện tích:', '25m²'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildLabel('Mô tả:'),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Make beds: Change sheets and pillowcases, fluff pillows, straighten blankets.',
                        style: TextStyle(fontSize: 14, fontFamily: 'Noto Sans'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildLabel('Người đăng:'),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF2F2F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage("https://placehold.co/18x18"),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('John Doe', style: TextStyle(fontSize: 14, fontFamily: 'Noto Sans')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildLabelValue('Địa chỉ:', '123/45 Nguyễn Văn Cừ, Q.5, TP.HCM'),
                const SizedBox(height: 4),
                _buildLabelValue('Ngày đăng:', '10/12/2023 16.00AM'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6EFD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('Xem chi tiết', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('Chuyển lại trạng thái chờ',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Row(
      children: [
        _buildLabel(label),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w600,
      ),
    );
  }
} 
