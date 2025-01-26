import 'package:asm2/screens/cart_page.dart';
import 'package:asm2/screens/orders_page.dart';
import 'package:asm2/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'restaurants_page.dart';
import 'maps_page.dart'; // 引入聊天机器人页面
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:asm2/screens/chatbot_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 当前选中的页面索引

  final List<Widget> _pages = [
    RestaurantsPage(),
    OrdersPage(),
    MapsPage(),
    ChatBotPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
          IconButton(
            onPressed: () => Provider.of<CustomAuthProvider>(context, listen: false).logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react, // 动画风格
        backgroundColor: Colors.blue, // 背景色
        color: Colors.white70, // 未选中项颜色
        activeColor: Colors.white, // 选中项颜色
        items: const [
          TabItem(icon: Icons.restaurant, title: 'Restaurants'),
          TabItem(icon: Icons.shopping_cart, title: 'Orders'),
          TabItem(icon: Icons.map, title: 'Map'),
          TabItem(icon: Icons.chat, title: 'Chatbot'),
          TabItem(icon: Icons.person, title: 'Profile'),
        ],
        initialActiveIndex: _selectedIndex, // 当前选中的索引
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
