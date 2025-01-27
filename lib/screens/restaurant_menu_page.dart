import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class RestaurantMenuPage extends StatelessWidget {
  final QueryDocumentSnapshot restaurant;

  const RestaurantMenuPage({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    // 获取菜单数据并处理类型
    final List<dynamic> menu = restaurant['menu'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          restaurant['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // 餐厅图片和信息
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      offset: Offset(0, 3),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: Image.network(
                    restaurant['image'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        height: 200,
                        child: Icon(Icons.broken_image, size: 100, color: Colors.grey.shade600),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    restaurant['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              restaurant['location'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Divider(thickness: 1, color: Colors.grey.shade300, height: 30),

          // 检查是否有菜单数据
          if (menu.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No menu items available',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ),
            )
          else
          // 菜单列表
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                itemCount: menu.length,
                itemBuilder: (context, index) {
                  final menuItem = menu[index] as Map<String, dynamic>;

                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          menuItem['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.fastfood, size: 50, color: Colors.grey.shade600);
                          },
                        ),
                      ),
                      title: Text(
                        menuItem['name'],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '\$${menuItem['price'] != null ? menuItem['price'].toStringAsFixed(2) : 'N/A'}',
                        style: TextStyle(color: Colors.teal.shade700),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.add_shopping_cart, color: Colors.teal),
                        onPressed: () {
                          final cartProvider = Provider.of<CartProvider>(context, listen: false);
                          cartProvider.addItem(
                            menuItem['name'], // id
                            menuItem['name'], // name
                            menuItem['price'], // price
                            menuItem['image'], // image
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${menuItem['name']} added to cart!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
