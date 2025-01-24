import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 2), () {
      final authProvider = Provider.of<CustomAuthProvider >(context, listen: false);
      authProvider.checkLoginStatus(); // 同步登录状态

      if (authProvider.user == null) {
        Navigator.pushReplacementNamed(context, '/login'); // 未登录，跳转到登录页
      } else {
        Navigator.pushReplacementNamed(context, '/home'); // 已登录，跳转到主界面
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.jpg', height: 100),
            SizedBox(height: 20),
            Text(
              'Food Delivery App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
