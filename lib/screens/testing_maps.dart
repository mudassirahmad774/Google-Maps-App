import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TestingMaps extends StatefulWidget {
  const TestingMaps({super.key});

  @override
  State<TestingMaps> createState() => _TestingMapsState();
}

class _TestingMapsState extends State<TestingMaps> {
  late GoogleMapController mapController;
  LatLng? _initialPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _determinePosition();
  }

  // function for getting use permission and position (lat long)
  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: _initialPosition!,
            infoWindow: const InfoWindow(title: "You are here"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
        _isLoading = false;
        print('Latitude--------> ${position.latitude}, Longitude: ${position.longitude}');
      });
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('My current Location'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _isLoading ? Center(child: CircularProgressIndicator()) :
          Expanded(
            child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialPosition!,
                  zoom: 14,
                ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
            ),
          ),
        ],
      ),
    );
  }
}
