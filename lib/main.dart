import 'package:asm2/providers/chat_provider.dart';
import 'package:asm2/screens/RestaurantsOverviewPage.dart';
import 'package:asm2/screens/chatbot_page.dart';
import 'package:asm2/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/chat_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/login_page.dart';
import 'screens/restaurants_page.dart';
import 'screens/AdminAddRestaurantPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomAuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(), // 添加一个启动页判断登录状态
        '/login': (context) => LoginPage(),
        '/home': (context) => HomeScreen(),
        '/admin-add-restaurant': (context) => AdminAddRestaurantPage(),
        '/restaurants-overview': (context) => RestaurantsOverviewPage(),
        '/chatbot': (context) => ChatBotPage(), // 新增聊天路由
      },
    );
  }
}




// SplashScreen 用于判断初始路由
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (user.email == 'admin@admin.com') {
          Navigator.pushReplacementNamed(context, '/restaurants-overview');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }



}