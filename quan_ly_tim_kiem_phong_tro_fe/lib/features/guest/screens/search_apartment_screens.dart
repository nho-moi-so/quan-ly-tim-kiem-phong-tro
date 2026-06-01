import 'package:flutter/material.dart';

import '../../../model/search_criteria.dart';
import '../../../model/post.dart';
import '../../../model/apartment.dart';

import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_address.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_search.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_cart.dart';

import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/bottom_tabbar.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/view_apartment_screens.dart';

class SearchApartmentScreens extends StatelessWidget {
  final SearchCriteria criteria;
  final List<Post> results;
  // thêm apartments
  final List<Apartment> apartments;

  const SearchApartmentScreens({
    super.key,
    required this.criteria,
    required this.results,
    required this.apartments,
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

            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text("Không tìm thấy phòng trọ nào"))
                  : ListView.builder(
                      itemCount: results.length,

                      itemBuilder: (context, index) {
                        final post = results[index];

                        // tìm apartment tương ứng
                        final apartment = apartments.firstWhere(
                          (apt) => apt.ApartmentID == post.apartmentID,
                          orElse: () => Apartment(
                            ApartmentID: '',
                            CodeApartment: '',
                            DailyRate: 0,
                            Deposit: 0,
                            maxOccupancy: 0,
                            description: '',
                            userId: '',
                            PathImage: [],
                            status: '',
                            password: '',
                            address: '',
                            Type: '',
                            Requirements: [],
                            Bedroom: '',
                            Bathroom: '',
                            amenities: [],
                            latitude: 0,
                            longitude: 0,
                          ),
                        );
                        if (apartment.ApartmentID.isEmpty) {
                          return const SizedBox();
                        }
                        print("POST ID: ${post.apartmentID}");

                        for (var apt in apartments) {
                          print("APT ID: ${apt.ApartmentID}");
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),

                          child: ApartmentCart(
                            post: post,
                            apartment: apartment,

                            onTap: () {
                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder: (context) => ViewApartmentScreens(
                                    post: post,
                                    apartment: apartment,
                                    criteria: criteria,
                                  ),
                                ),
                              );
                            },
                          ),
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
