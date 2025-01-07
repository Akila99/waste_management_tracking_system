import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic> wardDetails;

  const MapScreen({required this.wardDetails, Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _defaultCenter = const LatLng(6.902495, 79.854713);
  late String _mapStyle = '';
  bool _isStyleLoaded = false;
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  Set<Polygon> polygons = HashSet<Polygon>();
  List<LatLng> wardCoordinates = [];
  String wardName = "Ward Map";

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _extractWardDetails();
    _addWardPolygon();
  }

  // Load map style from assets
  void _loadMapStyle() async {
    try {
      _mapStyle = await DefaultAssetBundle.of(context)
          .loadString('map_theme/retro_theme.json');
      setState(() {
        _isStyleLoaded = true;
      });
    } catch (e) {
      debugPrint("Error loading map style: $e");
    }
  }

  // Extract ward name and coordinates from wardDetails
  void _extractWardDetails() {
    wardName = widget.wardDetails['ward_name'] ?? "Unknown Ward";

    if (widget.wardDetails['boundary'] != null &&
        widget.wardDetails['boundary']['coordinates'] != null) {
      final List<dynamic> coordinates = widget.wardDetails['boundary']['coordinates'];

      wardCoordinates = coordinates.map((coord) {
        // Assuming `coord` is of type `GeoPoint`
        if (coord is GeoPoint) {
          return LatLng(coord.latitude, coord.longitude);
        } else {
          return LatLng(0.0, 0.0); // Return a default value if the type is not GeoPoint
        }
      }).toList();

    }
  }

  // Add ward polygon based on given coordinates
  void _addWardPolygon() {
    if (wardCoordinates.isNotEmpty) {
      // Ensure polygon is closed
      if (wardCoordinates.first != wardCoordinates.last) {
        wardCoordinates.add(wardCoordinates.first);
      }

      setState(() {
        polygons.add(
          Polygon(
            polygonId: const PolygonId("ward_polygon"),
            points: wardCoordinates,
            strokeColor: Colors.blueAccent,
            strokeWidth: 3,
            fillColor: Colors.green.withOpacity(0.0), // Adjust opacity
            geodesic: true,
          ),
        );
      });

      debugPrint("Polygon added with ${wardCoordinates.length} points.");
    } else {
      debugPrint("No coordinates available for the ward boundary.");
    }
  }

  // Fetch current location
  Future<Position> currentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied. Cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Add user location marker
  void _addUserMarker(Position position) {
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId("user_location"),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: "Your Location"),
        ),
      );
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wardName),
        backgroundColor: Colors.lightGreen,
      ),
      body: _isStyleLoaded
          ? GoogleMap(
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
        markers: markers,
        polygons: polygons,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
          googleMapController.setMapStyle(_mapStyle);
        },
        initialCameraPosition: CameraPosition(
          target: wardCoordinates.isNotEmpty
              ? wardCoordinates.first
              : _defaultCenter,
          zoom: 16.0,
        ),
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          try {
            Position position = await currentPosition();
            _addUserMarker(position);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        },
        child: const Icon(Icons.my_location, size: 30),
      ),
    );
  }
}
