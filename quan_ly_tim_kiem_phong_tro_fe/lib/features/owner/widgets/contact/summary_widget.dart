import 'package:flutter/material.dart';

class SummaryWidget extends StatelessWidget {
  final String? imageUrl;
  final String? price;
  final String? deposit;
  final String? title;
  final String? address;
  final List<String>? features;

  const SummaryWidget({
    super.key,
    required this.imageUrl,
    required this.price,
    required this.deposit,
    required this.title,
    required this.address,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl!,
              width: 148,
              height: 111,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 148,
                height: 111,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.broken_image,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Thông tin bên phải
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên
                Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                // Giá cũ + Giá mới + % giảm
                Row(
                  children: [
                    // Flexible(
                    //   flex: 1,
                    //   child: Text(
                    //     deposit!,
                    //     style: TextStyle(
                    //       color: Colors.black.withOpacity(0.65),
                    //       fontSize: 12,
                    //       fontFamily: 'Inter',
                    //       fontWeight: FontWeight.w600,
                    //       // decoration: TextDecoration.lineThrough,
                    //     ),
                    //     overflow: TextOverflow.ellipsis,
                    //     maxLines: 1,
                    //   ),
                    // ),
                    // const SizedBox(width: 6),
                    Flexible(
                      flex: 2,
                      child: Text(
                        price!,
                        style: const TextStyle(
                          color: Color(0xFFF7210F),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Địa chỉ
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF4B5563),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address!,
                        style: const TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w300,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Các tiện ích
                ...features!.map(
                  (f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.check, color: Colors.green, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            f,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
