import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController _mapController;

  // 初始位置：旧金山
  final LatLng _initialPosition = LatLng(37.7749, -122.4194);

  // 添加一些标记
  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('marker_1'),
      position: LatLng(37.7749, -122.4194),
      infoWindow: InfoWindow(
        title: 'San Francisco',
        snippet: 'A beautiful city in California.',
      ),
    ),
    Marker(
      markerId: MarkerId('marker_2'),
      position: LatLng(34.0522, -118.2437), // 洛杉矶
      infoWindow: InfoWindow(
        title: 'Los Angeles',
        snippet: 'City of Angels.',
      ),
    ),
  };

  // 地图加载完成时的回调
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 移动摄像头到另一个位置（例如洛杉矶）
          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(34.0522, -118.2437), // 洛杉矶
                zoom: 10.0,
              ),
            ),
          );
        },
        child: Icon(Icons.map),
      ),
    );
  }
}
