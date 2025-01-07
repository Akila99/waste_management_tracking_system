import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic> wardDetails;

  MapScreen({required this.wardDetails});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _center = const LatLng(6.902495, 79.854713);
  late String _mapStyle = '';
  bool _isStyleLoaded = false;
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  Set<Polygon> polygons = HashSet<Polygon>();

  // Polygon Points (Example - replace with your wardDetails logic)
  List<LatLng> wardCoordinates = [
    const LatLng(6.907432, 79.849052),
    const LatLng(6.907875, 79.850778),
    const LatLng(6.908804, 79.850487),
    const LatLng(6.909383, 79.852409),
    const LatLng(6.909683, 79.852311),
    const LatLng(6.909912, 79.853057),
    const LatLng(6.910509, 79.854201),
    const LatLng(6.911957, 79.853696),
    const LatLng(6.911893, 79.856063),
    const LatLng(6.905993, 79.859004),
    const LatLng(6.902289, 79.850474),
    const LatLng(6.907432, 79.849052),
  ];

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _addWardPolygon();
  }

  // Load map style from assets
  void _loadMapStyle() async {
    _mapStyle = await DefaultAssetBundle.of(context)
        .loadString('map_theme/retro_theme.json');
    setState(() {
      _isStyleLoaded = true;
    });
  }

  // Add ward polygon based on given coordinates
  void _addWardPolygon() {
    polygons.add(
      Polygon(
        polygonId: const PolygonId("ward_polygon"),
        points: wardCoordinates,
        strokeColor: Colors.blueAccent,
        strokeWidth: 3,
        fillColor: Colors.green.withOpacity(0.0),
        geodesic: true,

      ),
    );
  }

  // Fetch current location
  Future<Position> currentPosition() async {
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
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
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
        title: const Text('Ward Map'),
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
          target: _center,
          zoom: 16.0,
        ),
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          Position position = await currentPosition();
          _addUserMarker(position);
        },
        child: const Icon(Icons.my_location, size: 30),
      ),
    );
  }
}
