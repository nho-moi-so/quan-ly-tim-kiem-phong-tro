import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/home_page_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/login_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/signup_email_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/welcome_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/view_contract_screens.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),

      initialRoute: '/welcomescreen',

      routes: {
        '/welcomescreen': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpEmailScreen(),
        '/home': (context) => const HomePageScreen(),
        //'/contract': (context) => const ViewContractScreens(),
        
      },
    );
  }
}