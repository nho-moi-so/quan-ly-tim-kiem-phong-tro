import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';

class Images extends StatelessWidget {
  final Apartment apartment;

  const Images({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    final List<String> thumbnailImages = apartment.PathImage ?? [];

    bool hasImages = thumbnailImages.isNotEmpty &&
        thumbnailImages[0].isNotEmpty &&
        thumbnailImages[0] != "null";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: hasImages
              ? Image.network(
                  thumbnailImages[0],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackImage(),
                )
              : _fallbackImage(),
        ),

        // Hiển thị danh sách ảnh nhỏ nếu có
        if (thumbnailImages.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: thumbnailImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final url = thumbnailImages[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: url.isEmpty || url == "null"
                        ? _fallbackThumb()
                        : Image.network(
                            url,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _fallbackThumb(),
                          ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 40),
      ),
    );
  }

  Widget _fallbackThumb() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported),
    );
  }
}
