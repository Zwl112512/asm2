import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  // 检查登录状态并同步
  void checkLoginStatus() {
    _user = _auth.currentUser;
    notifyListeners(); // 通知 UI 更新
  }

  // 用户登出
  Future<void> logout(BuildContext context) async {
    final bool? confirm = await _showLogoutConfirmationDialog(context);
    if (confirm == true) {
      await _auth.signOut();
      _user = null; // 清除本地用户状态
      notifyListeners(); // 通知 UI 更新
      Navigator.pushReplacementNamed(context, '/login'); // 跳转到登录页面
    }
  }

  // 显示登出确认对话框
  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // 用户取消
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // 用户确认
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
