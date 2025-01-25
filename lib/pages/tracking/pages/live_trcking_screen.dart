import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_management_tracking/pages/tracking/classes/bin_service.dart';
import 'dart:async';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';


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
  late BitmapDescriptor _truckIcon;
  final List<Map<String, dynamic>> _binLocations = [];

  @override
  void initState() {
    super.initState();
    _extractWardDetails();
    _loadBinData(
      widget.provinceId,
      widget.districtId,
      widget.councilId,
    );
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

  void _loadBinData(String provinceId, String districtId, String councilId) {
    try {
      _binDataLoader
          .fetchBinDetailsRealtime(wardName, provinceId, districtId, councilId, mounted)
          .listen((truckDetails) async {
        if (truckDetails.isNotEmpty) {
          // Pass truck details to _loadBinData to extract bin data
          await _loadBinDataRealtime(truckDetails); // Extract bin data
          // await _loadTruckMovements(truckDetails);

        }
      });
    } catch (e) {
      debugPrint("Error loading truck details: $e");
    }
  }


  Future<void> _loadBinDataRealtime(List<Map<String, dynamic>> truckDetails) async {
    // Clear existing bin locations before loading new data
    setState(() {
      _binLocations.clear();
    });

    for (var truck in truckDetails) {
      var schedule = truck['schedule'];

      if (schedule != null) {
        var nonRecycling = schedule['non_recycling'];
        if (nonRecycling != null && nonRecycling.isNotEmpty) {
          for (var nonRecyclingMap in nonRecycling) {
            var mondayReferenceData = nonRecyclingMap['Monday_reference_data'];
            print("Monday: $mondayReferenceData");

            if (mondayReferenceData != null && mondayReferenceData is Map<String, dynamic>) {
              var collectionPointRefs = mondayReferenceData['collection_point_ref'];
              print('COllection:$collectionPointRefs ');

              if (collectionPointRefs is List) {
                for (var collectionPointRef in collectionPointRefs) {
                  if (collectionPointRef is DocumentReference) {
                    collectionPointRef.snapshots().listen((collectionPointSnapshot) async {
                      if (collectionPointSnapshot.exists) {
                        var collectionPointData = collectionPointSnapshot.data();

                        if (collectionPointData is Map<String, dynamic>) {
                          String roadName = collectionPointData['road_name'] ?? 'Unknown';
                          var binLocationRef = collectionPointRef.collection('bin locations');
                          print('Road: $roadName');

                          // Listen for real-time updates in 'bin locations'
                          binLocationRef.snapshots().listen((binLocationSnapshot) {
                            for (var doc in binLocationSnapshot.docs) {
                              var binLocationData = doc.data();
                              var location = binLocationData['location'];

                              if (location != null && location is GeoPoint) {
                                double latitude = location.latitude;
                                double longitude = location.longitude;

                                // Update bin data in a coordinated way
                                setState(() {
                                  // Remove any old entry with the same bin_id
                                  _binLocations.removeWhere(
                                          (bin) => bin['bin_id'] == binLocationData['bin_id']);
                                  print("Road Name: $roadName");

                                  // Add updated bin data
                                  _binLocations.add({
                                    'latitude': latitude,
                                    'longitude': longitude,
                                    'status': binLocationData['status'],
                                    'road_name': roadName,
                                    'bin_id': binLocationData['bin_id'],
                                  });
                                });

                                // Call `_addBinMarkers` after updating `_binLocations`
                                _addBinMarkers(_binLocations);
                              } else {
                                print('Location is not a valid GeoPoint');
                              }
                            }
                          });
                        }
                      }
                    });
                  }
                }
              }
            }
          }
        }
      }
    }
  }



  void _addBinMarkers(List<Map<String, dynamic>> binData) async {
    Set<Marker> binMarkers = {};
    BitmapDescriptor binIcon = await _getBinIcon();

    for (var bin in binData) {
      print('bin data: $bin');
      Marker binMarker = Marker(
        markerId: MarkerId(bin['bin_id']),
        position: LatLng(bin['latitude'], bin['longitude']),
        icon: binIcon,
        infoWindow: InfoWindow(
          title: 'Road: ${bin['road_name']} ',
          snippet: 'Status: ${bin['status']}- Bin ID: ${bin['bin_id']}',

        ),
      );

      binMarkers.add(binMarker);
    }

    // Update markers on the map
    setState(() {
      _markers = binMarkers; // Replace existing markers with new ones
    });
  }

  Future<BitmapDescriptor> _getBinIcon() async {
    final ByteData data = await rootBundle.load('assets/images/bin_icon1.png');
    final Uint8List bytes = data.buffer.asUint8List();

    final img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;
    final img.Image resized = img.copyResize(image, width: 35, height: 35);
    final Uint8List resizedBytes = Uint8List.fromList(img.encodePng(resized));

    return BitmapDescriptor.bytes(resizedBytes);
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
        icon: BitmapDescriptor.defaultMarker,
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
