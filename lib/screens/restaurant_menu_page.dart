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
        title: Text(restaurant['name']),
      ),
      body: Column(
        children: [
          // 餐厅图片和信息
          Stack(
            children: [
              Image.network(
                restaurant['image'],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey,
                    height: 200,
                    child: Icon(Icons.image, size: 100),
                  );
                },
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Text(
                  restaurant['name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            restaurant['location'],
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
          Divider(),

          // 检查是否有菜单数据
          if (menu.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No menu items available',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          else
          // 菜单列表
            Expanded(
              child: ListView.builder(
                itemCount: menu.length,
                itemBuilder: (context, index) {
                  final menuItem = menu[index] as Map<String, dynamic>;

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          menuItem['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.image, size: 50);
                          },
                        ),
                      ),
                      title: Text(menuItem['name']),
                      subtitle: Text(
                        '\$${menuItem['price'] != null ? menuItem['price'].toStringAsFixed(2) : 'N/A'}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.add_shopping_cart),
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
