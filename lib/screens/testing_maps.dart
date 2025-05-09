import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_maps_webservice/places.dart';

const kGoogleApiKey = ''; // Replace with your API key
final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class TestingMaps extends StatefulWidget {
  const TestingMaps({super.key});

  @override
  State<TestingMaps> createState() => _TestingMapsState();
}

class _TestingMapsState extends State<TestingMaps> {
  late GoogleMapController mapController;
  LatLng? _initialPosition;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      print("Checking location service...");
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services are disabled.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print("Requesting location permission...");
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Location permission denied.';
      }
      if (permission == LocationPermission.deniedForever) throw 'Location permission permanently denied.';

      Position position = await Geolocator.getCurrentPosition();
      print("Current position: ${position.latitude}, ${position.longitude}");

      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: _initialPosition!,
            infoWindow: const InfoWindow(title: "You are here"),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _handleSearch() async {
    print("Search field tapped----------->");

    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      mode: Mode.overlay,
      language: "en",
      components: [Component(Component.country, "pk")],
    );

    if (p != null) {
      print("Prediction selected--------> ${p.description} (Place ID----> ${p.placeId})");

      final detail = await _places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      print("Selected place coordinates: Latitude -------> $lat, Longitude = $lng");

      LatLng newLocation = LatLng(lat, lng);
      mapController.animateCamera(CameraUpdate.newLatLngZoom(newLocation, 14));

      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('searchedLocation'),
            position: newLocation,
            infoWindow: InfoWindow(title: detail.result.name),
          ),
        );
      });

      print("Marker added for------> ${detail.result.name} at $newLocation");
    } else {
      print("No prediction selected.----------------->");
    }
  }

  List<Prediction> _suggestions = [];
  void _getPlaceSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _suggestions.clear();
      });
      return;
    }

    print("Searching for: $input");

    final response = await _places.autocomplete(
      input,
      language: "en",
      components: [Component(Component.country, "pk")],
    );

    if (response.isOkay) {
      print("Suggestions received: ${response.predictions.length}");
      setState(() {
        _suggestions = response.predictions;
      });
    } else {
      print("Autocomplete failed: ${response.errorMessage}");
    }
  }

  Future<void> _selectPlace(Prediction prediction) async {
    print("Selected place: ${prediction.description}");
    final detail = await _places.getDetailsByPlaceId(prediction.placeId!);
    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;
    LatLng newLocation = LatLng(lat, lng);

    mapController.animateCamera(CameraUpdate.newLatLngZoom(newLocation, 14));

    setState(() {
      _searchController.text = prediction.description!;
      _suggestions.clear();
      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('selectedPlace'),
        position: newLocation,
        infoWindow: InfoWindow(title: detail.result.name),
      ));
    });

    print("Moved to $newLocation");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 5),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search location...',
                            border: InputBorder.none,
                            icon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            _getPlaceSuggestions(value);
                          },
                        ),
                      ),
                    ),
                    if (_suggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        height: 200,
                        child: ListView.builder(
                          itemCount: _suggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = _suggestions[index];
                            return ListTile(
                              title: Text(suggestion.description ?? ""),
                              onTap: () {
                                _selectPlace(suggestion);
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      height: 600,
                      width: 400,
                      child: GoogleMap(
                        onMapCreated: (controller) {
                          mapController = controller;
                          print("Map created");
                        },
                        initialCameraPosition: CameraPosition(
                          target: _initialPosition!,
                          zoom: 14,
                        ),
                        markers: _markers,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
