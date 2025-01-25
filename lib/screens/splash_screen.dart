import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? imageUrl; // 存储 Firebase Storage 图片 URL
  bool isImageLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    try {
      // 获取图片 URL
      final ref = FirebaseStorage.instance.ref('profile_images/mqMk7jUCbPStMv1iTA0VBXLZCxc2.jpg');
      final url = await ref.getDownloadURL();

      // 加载完成后更新状态
      setState(() {
        imageUrl = url;
        isImageLoaded = true;
      });

      // 延迟一定时间后导航
      Future.delayed(Duration(seconds: 4), () {
        final authProvider = Provider.of<CustomAuthProvider>(context, listen: false);
        authProvider.checkLoginStatus();

        if (authProvider.user == null) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isImageLoaded)
              Image.network(imageUrl!, height: 100) // Firebase Storage 的图片
            else
              CircularProgressIndicator(), // 显示加载指示器
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
