// apartment_card.dart
import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/post.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';

class ApartmentCard extends StatelessWidget {
  final Post post;
  final Apartment apartment;
  final VoidCallback onTap;

  const ApartmentCard({
    super.key,
    required this.post,
    required this.apartment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh - Sửa PathImage thành pathImage
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                apartment.PathImage.isNotEmpty 
                    ? apartment.PathImage.first 
                    : 'https://via.placeholder.com/400x250',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên căn hộ + Trạng thái
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          apartment.CodeApartment.isNotEmpty 
                              ? apartment.CodeApartment 
                              : (post.header ?? 'Căn hộ'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (apartment.status.toLowerCase() == 'available' || 
                                 apartment.status.toUpperCase() == 'AVAILABLE') 
                              ? Colors.green 
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (apartment.status.toLowerCase() == 'available' || 
                           apartment.status.toUpperCase() == 'AVAILABLE') 
                              ? 'Còn trống' 
                              : 'Đã thuê',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Giá
                  Text(
                    '${apartment.DailyRate.toStringAsFixed(0)}k / ngày',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Vị trí
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          apartment.address.isNotEmpty 
                              ? apartment.address 
                              : 'Chưa có địa chỉ',
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Thông tin thêm
                  Row(
                    children: [
                      _infoChip('${apartment.Bedroom} PN'),
                      const SizedBox(width: 8),
                      _infoChip('${apartment.Bathroom} WC'),
                      const SizedBox(width: 8),
                      _infoChip('${apartment.maxOccupancy} người'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}