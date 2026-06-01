import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApartmentCart extends StatelessWidget {
  final Apartment apartment;
  final Post post;

  // THÊM
  final VoidCallback? onTap;

  const ApartmentCart({
    super.key,
    required this.apartment,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth * 0.9;
    final double imageHeight = cardWidth * 0.6;

    return Center(
      child: GestureDetector(
        onTap: onTap,

        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          width: cardWidth,

          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),

            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),

                    child:
                        apartment.PathImage.isNotEmpty
                            ? Image.network(
                              apartment.PathImage.first,
                              width: cardWidth,
                              height: imageHeight,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              width: cardWidth,
                              height: imageHeight,
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 60,
                              ),
                            ),
                  ),

                  Positioned(
                    bottom: 10,
                    right: 10,

                    child: Container(
                      padding: const EdgeInsets.all(6),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade400,
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,

                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),

                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius:
                                  BorderRadius.circular(4),
                            ),

                            child: Text(
                              "Giá hôm nay",

                              style: TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "Đặt cọc: ${apartment.Deposit}",

                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          Text(
                            "Giá phòng: ${apartment.DailyRate}",

                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(10),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      post.header,

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      apartment.Type,
                    ),

                    Text(
                      "Sức chứa: ${apartment.maxOccupancy} người",
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            apartment.address,

                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),

                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      post.description,

                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}