import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_address.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_search.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_cart.dart';

class SearchApartmentScreens extends StatelessWidget {
  const SearchApartmentScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trang chủ")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            ApartmentAddress(),
            ApartmentSearch(),
            ApartmentCart(),
          
          ],
        ),
      ),
    );
  }
}
