import 'package:flutter/material.dart';
import 'package:google_maps_app/screens/map_first_screen.dart';
import 'package:google_maps_app/screens/map_search_location/map_search_location.dart';
import 'package:google_maps_app/screens/map_search_location/map_search_testing.dart';
import 'package:google_maps_app/screens/testing_maps.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  const MapSearchTesting(),
    );
  }
}
