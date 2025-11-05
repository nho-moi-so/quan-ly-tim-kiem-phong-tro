import 'package:flutter/material.dart';
import '../../../model/search_criteria.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_address.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_search.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_cart.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/bottom_tabbar.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/view_apartment_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/search_criteria.dart';

class SearchApartmentScreens extends StatelessWidget {
  final SearchCriteria criteria;
  final List<Apartment> results;

  const SearchApartmentScreens({
    super.key,
    required this.criteria,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${criteria.address ?? 'Tất cả'} (${results.length})",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ApartmentAddress(
              address: criteria.address ?? "Chưa có địa chỉ",
              dateRange: (criteria.checkIn != null && criteria.checkOut != null)
                  ? "${criteria.checkIn!.day}/${criteria.checkIn!.month} - ${criteria.checkOut!.day}/${criteria.checkOut!.month}"
                  : "Chưa chọn ngày",
              guestCount: criteria.maxOccupancy ?? 1,
              resultCount: results.length,
            ),

            const SizedBox(height: 12),
            const ApartmentSearch(),
            const SizedBox(height: 16),

            // Phần danh sách
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text("Không tìm thấy phòng trọ nào"))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final apartment = results[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewApartmentScreens(
                                  apartment: apartment,
                                  criteria:
                                      criteria, 
                                ),
                              ),
                            );
                          },
                          child: ApartmentCart(apartment: apartment),
                        );
                      },
                    ),
            ),
            const BottomTabbar(),
          ],
        ),
      ),
    );
  }
}
