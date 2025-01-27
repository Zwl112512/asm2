import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asm2/screens/restaurant_details_page.dart';
import 'AdminAddRestaurantPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RestaurantsOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurants Overview'),
        actions: [
          IconButton(
            icon: Icon(Icons.add), // 添加餐厅按钮
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminAddRestaurantPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final restaurants = snapshot.data!.docs;

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return ListTile(
                title: Text(restaurant['name']),
                subtitle: Text(restaurant['location']),
                leading: Image.network(
                  restaurant['image'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // 删除确认对话框
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Restaurant'),
                        content: Text(
                            'Are you sure you want to delete this restaurant?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await FirebaseFirestore.instance
                          .collection('restaurants')
                          .doc(restaurant.id)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Restaurant deleted successfully!')),
                      );
                    }
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantDetailsPage(
                        restaurantId: restaurant.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
