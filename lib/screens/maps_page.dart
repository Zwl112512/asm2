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
  LatLng _initialPosition = const LatLng(0, 0);
  final Set<Marker> _markers = {};
  bool _isLocationFetched = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

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

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _isLocationFetched = true;
    });

    if (_mapController != null) {
      _moveCameraToCurrentLocation();
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fetchMarkersFromFirebase();

    if (_isLocationFetched) {
      _moveCameraToCurrentLocation();
    }
  }

  void _moveCameraToCurrentLocation() {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _initialPosition,
          zoom: 15.0,
        ),
      ),
    );
  }

  Future<void> _fetchMarkersFromFirebase() async {
    try {
      final querySnapshot =
      await FirebaseFirestore.instance.collection('restaurants').get();

      setState(() {
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          if (data.containsKey('latitude') &&
              data.containsKey('longitude') &&
              data.containsKey('name') &&
              data.containsKey('location')) {
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
        title: Text('Nearby Restaurants'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _getCurrentLocation(),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 10.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            bottom: 100,
            right: 5,
            child: FloatingActionButton(
              onPressed: _moveCameraToCurrentLocation,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
