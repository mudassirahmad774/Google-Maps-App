import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

import '../constant.dart';

final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class MapSearchTesting extends StatefulWidget {
  const MapSearchTesting({super.key});

  @override
  State<MapSearchTesting> createState() => _MapSearchTestingState();
}

class _MapSearchTestingState extends State<MapSearchTesting> {
  TextEditingController searchController = TextEditingController();
  List<Prediction> predictionList = [];

  // get places

  Future<void> getPlaces(String userInput) async {
    try {
      final response = await _places.autocomplete(
        searchController.text,
        language: 'en',
        components: [Component(Component.country, "ca")],
      );

      if (response.isOkay) {
        setState(() {
          predictionList = response.predictions;
        });
      } else {
        print('error-------->');
      }
    } catch (error) {
      print('error-------->$error');
    }
  }

  // on select place
  Future<void> selectPlace(Prediction prediction) async {
    final detail = await _places.getDetailsByPlaceId(prediction.placeId!);
    final lat = detail.result.geometry?.location.lat;
    final long = detail.result.geometry?.location.lng;

    LatLng newLocation = LatLng(lat!, long!);

    setState(() {
      searchController.text = prediction.description!;
      predictionList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),

            // Text Field

            TextField(
              controller: searchController,
              decoration: InputDecoration(
                  hintText: 'Search Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  )),
              onChanged: getPlaces,
            ),

            SizedBox(
              height: 20,
            ),

            //if(prediction.isEmpty)
            // PREDICTIONS
            Container(
              height: 200,
              color: Colors.grey.shade200,
              child: ListView.builder(
                  itemCount: predictionList.length,
                  itemBuilder: (context, index) {
                    final prediction2 = predictionList[index];

                    print('length ------> ${predictionList.length}');

                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          selectPlace(prediction2);
                        },
                        child: Text(
                          '${prediction2.description}',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
