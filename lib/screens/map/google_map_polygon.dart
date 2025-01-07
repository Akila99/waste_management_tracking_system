import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapPolygon extends StatefulWidget {
  const GoogleMapPolygon({super.key});

  @override
  State<GoogleMapPolygon> createState() => _GoogleMapPolygonState();
}

class _GoogleMapPolygonState extends State<GoogleMapPolygon> {
  LatLng myCurrentLocation = const LatLng(6.9271,  79.8612);
  final Completer<GoogleMapController> _completer = Completer();

  Set<Marker> markers = {};

  Set<Polygon> polygone = HashSet<Polygon>();
  List<LatLng> points = [
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
    const LatLng(6.905596, 79.858604),
    const LatLng(6.905371, 79.858581),
    const LatLng(6.904727, 79.858500),
    const LatLng(6.904160, 79.858424),
    const LatLng(6.903712, 79.858480),
    const LatLng(6.902373, 79.858902),
    const LatLng(6.901303, 79.859241),
    const LatLng(6.900106, 79.859641),
    const LatLng(6.899504, 79.859840),
    const LatLng(6.898883, 79.860431),
    // const LatLng(28.590588580409996, 81.62249412839972),
    // const LatLng(28.590588580409996, 81.62249412839972),
    // const LatLng(28.590588580409996, 81.62249412839972),
    // const LatLng(28.590588580409996, 81.62249412839972),
    const LatLng(6.898798, 79.860592),
    const LatLng(6.898245, 79.860374),
    const LatLng(6.897960, 79.858972),
    const LatLng(6.897632, 79.858879),
    const LatLng(6.896247, 79.854677),
    const LatLng(6.893812, 79.855419),
    const LatLng(6.893114, 79.852916),
    const LatLng(6.893305, 79.852875),
    const LatLng(6.893518, 79.852807),
    const LatLng(6.893841, 79.852705),
    const LatLng(6.894245, 79.852574),
    const LatLng(6.894610, 79.852457),
    const LatLng(6.894924, 79.852355),
    const LatLng(6.895283, 79.852238),
    const LatLng(6.895604, 79.852164),
    const LatLng(6.896033, 79.852065),
    const LatLng(6.896438, 79.851972),
    const LatLng(6.897525, 79.851740),
    const LatLng(6.902289, 79.850474),
    const LatLng(6.907432, 79.849052),
  ];
  void addPolygon() {
    polygone.add(
      Polygon(
        polygonId: const PolygonId("Id"),
        points: points,
        strokeColor: Colors.blueAccent,
        strokeWidth: 5,
        fillColor: Colors.green.withOpacity(0.0),
        geodesic: true,
      ),
    );
  }

  @override
  void initState() {
    addPolygon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      polygons: polygone,
      myLocationButtonEnabled: false,
      markers: markers,
      initialCameraPosition: CameraPosition(
        target: myCurrentLocation,
        zoom: 14,
      ),
      onMapCreated: (GoogleMapController controller) {
        _completer.complete(controller);
      },
    );
  }
}