
// import 'package:asm2/screens/chat_bot_page.dart';
import 'package:asm2/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_page.dart';
import 'screens/restaurants_page.dart';
import 'screens/AdminAddRestaurantPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // 确保 Firebase 初始化
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomAuthProvider ()), // 确保在根部注册
        ChangeNotifierProvider(create: (_) => CartProvider()), // 购物车状态
      ],
      child: MaterialApp(
        title: 'Food Delivery App',
        theme: ThemeData(primarySwatch: Colors.orange),
        initialRoute: '/',

        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => LoginPage(),
          '/home': (context) => HomeScreen(),
          '/restaurants': (context) => RestaurantsPage(),
          '/addRestaurant': (context) => AdminAddRestaurantPage(),


        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
