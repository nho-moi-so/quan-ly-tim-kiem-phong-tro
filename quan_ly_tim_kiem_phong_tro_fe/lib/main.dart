import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/call_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/chat_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/home_page_menu_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/home_page_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/my_booking_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/search_apartment_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/view_apartment_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/view_contract_screens.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Tìm Kiếm Phòng Trọ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ViewContractScreens(), 
    );
  }
}
