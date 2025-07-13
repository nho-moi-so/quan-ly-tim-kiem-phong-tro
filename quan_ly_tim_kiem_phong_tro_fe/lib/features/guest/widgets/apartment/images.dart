import 'package:flutter/material.dart';

class Images extends StatelessWidget {
  const Images({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> thumbnailImages = [
      'assets/images/tro1.png',
      'assets/images/tro1-1.png',
      'assets/images/tro1-2.png',
      'assets/images/tro1-3.png',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.asset(thumbnailImages[0], fit: BoxFit.cover),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: thumbnailImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    thumbnailImages[index],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
