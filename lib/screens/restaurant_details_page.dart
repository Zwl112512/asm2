import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/firebase_storage_helper.dart';

class RestaurantDetailsPage extends StatefulWidget {
  final String restaurantId;

  RestaurantDetailsPage({required this.restaurantId});

  @override
  _RestaurantDetailsPageState createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  File? _restaurantImage;
  List<Map<String, dynamic>> menuItems = [];

  @override
  void initState() {
    super.initState();
    _loadRestaurantDetails();
  }

  Future<void> _loadRestaurantDetails() async {
    final doc = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      nameController.text = data['name'];
      locationController.text = data['location'];
      latitudeController.text = data['latitude'].toString();
      longitudeController.text = data['longitude'].toString();
      menuItems = List<Map<String, dynamic>>.from(data['menu']);
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _restaurantImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateRestaurant() async {
    String? imageUrl;

    if (_restaurantImage != null) {
      imageUrl = await FirebaseStorageHelper.uploadImage(
        _restaurantImage!,
        'restaurant_images',
      );
    }

    await FirebaseFirestore.instance.collection('restaurants').doc(widget.restaurantId).update({
      'name': nameController.text.trim(),
      'location': locationController.text.trim(),
      'latitude': double.parse(latitudeController.text.trim()),
      'longitude': double.parse(longitudeController.text.trim()),
      'image': imageUrl ?? '', // 如果没有新图片，保留原来的图片
      'menu': menuItems,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Restaurant updated successfully')),
    );
    Navigator.pop(context);
  }

  Future<void> _editMenuItem(int index) async {
    final TextEditingController menuItemNameController = TextEditingController();
    final TextEditingController menuItemPriceController = TextEditingController();
    File? menuItemImageFile;

    menuItemNameController.text = menuItems[index]['name'];
    menuItemPriceController.text = menuItems[index]['price'].toString();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Menu Item'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: menuItemNameController,
                decoration: InputDecoration(labelText: 'Food Name'),
              ),
              TextField(
                controller: menuItemPriceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final selectedImage =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (selectedImage != null) {
                    setState(() {
                      menuItemImageFile = File(selectedImage.path);
                    });
                  }
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                  ),
                  child: menuItemImageFile == null
                      ? Icon(Icons.add_a_photo, size: 50)
                      : Image.file(menuItemImageFile!, fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (menuItemImageFile != null) {
                final imageUrl = await FirebaseStorageHelper.uploadImage(
                  menuItemImageFile!,
                  'menu_images',
                );

                menuItems[index]['image'] = imageUrl;
              }

              menuItems[index]['name'] = menuItemNameController.text.trim();
              menuItems[index]['price'] =
                  double.parse(menuItemPriceController.text.trim());

              setState(() {});
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurant Details"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateRestaurant,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: _restaurantImage == null
                    ? Image.network(
                  '',
                  fit: BoxFit.cover,
                )
                    : Image.file(
                  _restaurantImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Restaurant Name'),
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: latitudeController,
              decoration: InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: longitudeController,
              decoration: InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Text(
              "Menu:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text("\$${item['price']}"),
                  leading: Image.network(
                    item['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editMenuItem(index),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
