import 'package:flutter/material.dart';
import 'package:google_maps_app/screens/testing_maps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

// Constants
final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

// Main Widget
class MapSearchLocation extends StatefulWidget {
  const MapSearchLocation({super.key});

  @override
  State<MapSearchLocation> createState() => _MapSearchLocationState();
}

class _MapSearchLocationState extends State<MapSearchLocation> {
  final TextEditingController _searchController = TextEditingController();
  List<Prediction> _suggestions = [];

  // Get suggestions as user types
  void _getPlaceSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() => _suggestions.clear());
      return;
    }

    print("Searching for: $input");

    final response = await _places.autocomplete(
      input,
      language: "en",
      // components: [Component(Component.country, "pk")],
    );

    if (response.isOkay) {
      print("Suggestions received: ${response.predictions.length}");
      setState(() => _suggestions = response.predictions);
    } else {
      print("Autocomplete failed: ${response.errorMessage}");
    }
  }

  // Select a suggested place
  Future<void> _selectPlace(Prediction prediction) async {
    print("Selected place-------> ${prediction.description}");

    final detail = await _places.getDetailsByPlaceId(prediction.placeId!);
    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;
    LatLng newLocation = LatLng(lat, lng);

    setState(() {
      _searchController.text = prediction.description!;
      _suggestions.clear();
    });

    print("Moved to-------> $newLocation");
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50),
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
                onChanged: _getPlaceSuggestions,
              ),
            ),
          ),
          if (_suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    title: Text(suggestion.description ?? ""),
                    onTap: () => _selectPlace(suggestion),
                  );
                },
              ),
            ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
