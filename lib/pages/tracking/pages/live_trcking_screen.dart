import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_management_tracking/pages/tracking/classes/bin_service.dart';

class LiveTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> wardDetails;
  final String provinceId;
  final String districtId;
  final String councilId;

  const LiveTrackingScreen({
    Key? key,
    required this.wardDetails,
    required this.provinceId,
    required this.districtId,
    required this.councilId,
  }) : super(key: key);

  @override
  _LiveTrackingScreenState createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  GoogleMapController? _googleMapController;
  Set<Marker> _markers = {};
  String wardName = "Ward Map";
  List<LatLng> wardCoordinates = [];
  final BinDataLoader _binDataLoader = BinDataLoader();

  @override
  void initState() {
    super.initState();
    _extractWardDetails();
    _listenToDriverLocation(
      widget.provinceId,
      widget.districtId,
      widget.councilId,
    );
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  void _extractWardDetails() {
    wardName = widget.wardDetails['ward_name'] ?? "Unknown Ward";

    if (widget.wardDetails['boundary'] != null &&
        widget.wardDetails['boundary']['coordinates'] != null) {
      final List<dynamic> coordinates =
      widget.wardDetails['boundary']['coordinates'];

      wardCoordinates = coordinates.map((coord) {
        if (coord is GeoPoint) {
          return LatLng(coord.latitude, coord.longitude);
        } else {
          return const LatLng(0.0, 0.0);
        }
      }).toList();
    }
  }

  void _listenToDriverLocation(String provinceId, String districtId, String councilId) {
    try {
      _binDataLoader
          .fetchBinDetailsRealtime(wardName, provinceId, districtId, councilId, mounted)
          .listen((truckDetails) async {
        if (truckDetails.isNotEmpty) {
          // Iterate over each truck's details
          for (var truck in truckDetails) {
            // Extract the drivers array from the truck details
            var drivers = truck['drivers'] ?? [];

            // Iterate through the drivers list to check each driver's status
            for (var driverId in drivers) {
              // Fetch the driver's document from Firestore by their ID
              FirebaseFirestore.instance
                  .collection('drivers')
                  .doc(driverId)  // Assuming driverId is the document ID in Firestore
                  .snapshots()
                  .listen((DocumentSnapshot snapshot) {
                if (snapshot.exists) {
                  final data = snapshot.data() as Map<String, dynamic>;

                  // Check if the driver is active
                  if (data['status'] == 'active') {
                    // Get the truck_live_location (GeoPoint) for the active driver
                    if (data.containsKey('truck_live_location')) {
                      GeoPoint geoPoint = data['truck_live_location'];
                      LatLng driverLocation = LatLng(geoPoint.latitude, geoPoint.longitude);

                      debugPrint("Active Driver Location: ${driverLocation.latitude}, ${driverLocation.longitude}");

                      // Update the map marker with the driver's live location
                      _updateDriverMarker(driverLocation);
                    }
                  } else {
                    debugPrint("Driver $driverId is not active.");
                  }
                } else {
                  debugPrint("Driver document not found for $driverId.");
                }
              });
            }
          }
        }
      });
    } catch (e) {
      debugPrint("Error loading truck details: $e");
    }
  }

  void _updateDriverMarker(LatLng driverLatLng) {
    setState(() {
      // Remove existing driver marker
      _markers.removeWhere((marker) => marker.markerId.value == 'driver_marker');

      // Add a new marker for the driver
      _markers.add(Marker(
        markerId: MarkerId('driver_marker'),
        position: driverLatLng,
        infoWindow: InfoWindow(
          title: 'Driver Location',
          snippet:
          'Lat: ${driverLatLng.latitude}, Lng: ${driverLatLng.longitude}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));

      // Animate the camera to focus on the driver's location
      _googleMapController?.animateCamera(
        CameraUpdate.newLatLngZoom(driverLatLng, 17),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Tracking"),
        backgroundColor: Colors.green,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0), // Default location (set to your needs)
          zoom: 5,
        ),
        onMapCreated: (GoogleMapController controller) {
          _googleMapController = controller;
        },
        markers: _markers,
      ),
    );
  }
}
