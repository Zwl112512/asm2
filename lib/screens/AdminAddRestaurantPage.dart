import 'dart:io';
import 'package:flutter/material.dart';
import '../providers/image_picker_helper.dart';
import '../providers/firebase_storage_helper.dart';
import '../providers/firestore_helper.dart';

class AdminAddRestaurantPage extends StatefulWidget {
  @override
  _AdminAddRestaurantPageState createState() => _AdminAddRestaurantPageState();
}

class _AdminAddRestaurantPageState extends State<AdminAddRestaurantPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  File? _imageFile;
  List<Map<String, dynamic>> menuItems = [];

  Future<void> _pickImage() async {
    final selectedImage = await ImagePickerHelper.pickImageFromGallery();
    if (selectedImage != null) {
      setState(() {
        _imageFile = selectedImage;
      });
    }
  }

  Future<void> _saveRestaurant() async {
    if (_imageFile == null ||
        nameController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        latitudeController.text.trim().isEmpty ||
        longitudeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select an image')),
      );
      return;
    }

    if (menuItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menu must have at least one item')),
      );
      return;
    }

    try {
      final imageUrl = await FirebaseStorageHelper.uploadImage(_imageFile!, 'restaurant_images');

      if (imageUrl != null) {
        await FirestoreHelper.addDocument('restaurants', {
          'name': nameController.text.trim(),
          'location': locationController.text.trim(),
          'latitude': double.parse(latitudeController.text.trim()),
          'longitude': double.parse(longitudeController.text.trim()),
          'image': imageUrl,
          'menu': menuItems,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restaurant added successfully')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Image upload failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add restaurant: $e')),
      );
    }
  }

  Future<void> _addMenuItem() async {
    final TextEditingController menuItemNameController = TextEditingController();
    final TextEditingController menuItemPriceController = TextEditingController();
    File? menuItemImageFile;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Menu Item', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  final selectedImage = await ImagePickerHelper.pickImageFromGallery();
                  if (selectedImage != null) {
                    setState(() {
                      menuItemImageFile = selectedImage;
                    });
                  }
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: menuItemImageFile == null
                      ? Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(menuItemImageFile!, fit: BoxFit.cover),
                  ),
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
              if (menuItemImageFile == null ||
                  menuItemNameController.text.isEmpty ||
                  menuItemPriceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }

              final imageUrl = await FirebaseStorageHelper.uploadImage(
                menuItemImageFile!,
                'menu_images',
              );

              if (imageUrl != null) {
                setState(() {
                  menuItems.add({
                    'name': menuItemNameController.text.trim(),
                    'price': double.parse(menuItemPriceController.text.trim()),
                    'image': imageUrl,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Restaurant', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Restaurant Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: latitudeController,
              decoration: InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: longitudeController,
              decoration: InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _imageFile == null
                    ? Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addMenuItem,
              child: Text('Add Menu Item'),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final menuItem = menuItems[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        menuItem['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(menuItem['name']),
                    subtitle: Text('\$${menuItem['price'].toStringAsFixed(2)}'),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveRestaurant,
              child: Text('Save Restaurant'),
            ),
          ],
        ),
      ),
    );
  }
}
