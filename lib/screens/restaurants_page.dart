import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'restaurant_menu_page.dart'; // 引入菜单页面

class RestaurantsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurants'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No restaurants found.'));
          }

          final restaurants = snapshot.data!.docs;

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              print('Document data: ${restaurant.data()}'); // 调试输出

              // 确保字段存在并提供默认值
              final restaurantData = restaurant.data() as Map<String, dynamic>;
              final name = restaurantData['name'] ?? 'Unknown Restaurant';
              final location = restaurantData['location'] ?? 'Unknown Location';
              final image = restaurantData['image'] ?? '';

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: image.isNotEmpty
                        ? Image.network(
                      image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image, size: 60);
                      },
                    )
                        : Icon(Icons.image, size: 60),
                  ),
                  title: Text(name),
                  subtitle: Text(location),
                  onTap: () {
                    // 跳转到餐厅菜单页面
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RestaurantMenuPage(restaurant: restaurant),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
