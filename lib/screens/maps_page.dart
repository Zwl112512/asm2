import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController _mapController;
  LatLng _initialPosition = const LatLng(0, 0); // 初始化为 (0, 0)
  final Set<Marker> _markers = {};
  bool _isLocationFetched = false; // 用于标记是否已经获取到位置

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

// 获取当前位置
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 检查位置服务是否启用
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // 检查位置权限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // 获取当前位置
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _isLocationFetched = true;
    });

    // 打印获取到的经纬度信息
    print('Current latitude: ${position.latitude}, longitude: ${position.longitude}');

    // 如果地图控制器已经初始化，移动相机到当前位置
    if (_mapController != null) {
      _moveCameraToCurrentLocation();
    }
  }

  // 地图加载完成时的回调
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fetchMarkersFromFirebase();

    // 如果已经获取到位置，移动相机到当前位置
    if (_isLocationFetched) {
      _moveCameraToCurrentLocation();
    }
  }

  // 移动相机到当前位置
  void _moveCameraToCurrentLocation() {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _initialPosition,
          zoom: 15.0, // 调整缩放级别，可根据需要修改
        ),
      ),
    );
  }

  // 从 Firebase 获取餐厅位置
  Future<void> _fetchMarkersFromFirebase() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('restaurants').get();

      setState(() {
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          if (data.containsKey('latitude') && data.containsKey('longitude') &&
              data.containsKey('name') && data.containsKey('location')) {
            final marker = Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(data['latitude'], data['longitude']),
              infoWindow: InfoWindow(
                title: data['name'],
                snippet: data['location'],
              ),
            );
            _markers.add(marker);
          }
        }
      });
    } catch (e) {
      print('Error fetching markers from Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch restaurant locations.')),
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps Example'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 10.0,
        ),
        markers: _markers,
        myLocationEnabled: true, // 开启显示当前位置
        myLocationButtonEnabled: true, // 开启显示定位按钮
      ),
    );
  }
}