import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/common/screens/register_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/socket_service.dart';

import 'features/common/screens/login_screens.dart';
import 'features/owner/screens/otp_display_screen.dart';
import 'features/owner/screens/screens.dart';
import 'service/navigation_service.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    
    // Load .env file BEFORE creating SocketService
    await dotenv.load(fileName: ".env");
    
    // Khởi tạo SocketService sau khi dotenv được load
    final socketService = SocketService();
    print('🚀 Main: SocketService created');

    runApp(
      ChangeNotifierProvider.value(
        value: socketService,
        child: const MyApp(),
      ),
    );
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Quản lý phòng trọ',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        // Thêm hỗ trợ tiếng Việt
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('vi', 'VN'), // Tiếng Việt
          Locale('en', 'US'), // Tiếng Anh
        ],
        locale: const Locale('vi', 'VN'), // Set mặc định là tiếng Việt
        navigatorKey: navigationService.navigatorKey, // ← BẮT BUỘC
        initialRoute: '/login', // Đổi từ '/' sang '/main'
        routes: {
          '/main': (context) => const OwnerMainScreen(), // Thêm route mới
          '/messages': (context) => const MessageScreen(),
          '/apartments': (context) => const ApartmentScreen(),
          '/posts': (context) => const PostScreen(),
          '/bookings': (context) => BookingRequestScreens(),
          '/dashboard': (context) => const DashboardScreen(),
          '/login': (context) => const LoginScreens(),
          '/register': (context) => const RegisterScreens(),
          '/iot-test': (context) => const OtpDisplayScreen(), // ← Test IOT screen
  },
  // Handle parameterized routes (post detail, chat with args)
        onGenerateRoute: (settings) {
          if (settings.name == '/post/detail') {
            final args = settings.arguments as Map<String, dynamic>?;
            final postId = args?['postId'] as String?;
            return MaterialPageRoute(
              builder: (_) => DetailPostScreen(postId: postId ?? ''),
            );
          }

          if (settings.name == '/chat') {
            final args = settings.arguments as Map<String, dynamic>?;
            final chatItem = args?['chatItem'];
            // Expect caller to pass ChatItemViewModel instance
            return MaterialPageRoute(
              builder: (_) => ChatScreen(chatItem: chatItem),
            );
          }

          if (settings.name == '/contract/detail') {
            final args = settings.arguments as Map<String, dynamic>?;
            final contractId = args?['contractId'] as String?;
            return MaterialPageRoute(
              builder: (_) => ContractDetailScreen(contractId: contractId ?? ''),
            );
          }

          return null;
        },
        
      );
    }
  }

  class MyHomePage extends StatefulWidget {
    const MyHomePage({super.key, required this.title});


    final String title;

    @override
    State<MyHomePage> createState() => _MyHomePageState();
  }

  class _MyHomePageState extends State<MyHomePage> {
    int _counter = 0;

    void _incrementCounter() {
      setState(() {
        _counter++;
      });
    }

    @override
    Widget build(BuildContext context) {
    
      return Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('You have pushed the button this many times:'),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
    }
  }
