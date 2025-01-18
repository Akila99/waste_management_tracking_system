import 'dart:async';
import 'dart:collection';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:waste_management_tracking/pages/tracking/classes/truck_service.dart';
// import 'package:custom_info_window/custom_info_window.dart';



class MapScreen extends StatefulWidget {
  final Map<String, dynamic> wardDetails;
  final String provinceId;
  final String districtId;
  final String councilId;

  const MapScreen({
    required this.wardDetails,
    required this.provinceId,
    required this.districtId,
    required this.councilId,
    Key? key,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _defaultCenter = const LatLng(6.879385, 79.859828);
  late String _mapStyle = '';
  bool _isStyleLoaded = false;
  late GoogleMapController googleMapController;
  Set<Marker> _markers = {};
  Set<Marker> markers = {};
  Set<Polygon> polygons = HashSet<Polygon>();
  List<LatLng> wardCoordinates = [];
  String wardName = "Ward Map";
  LatLng? _truckLocation;
  final List<Map<String, dynamic>> _binLocations = [];
  final List<Map<String, dynamic>> _binTrackLocations = [];
  final List<Map<String, dynamic>> _truckRoutes = [];

  final TruckService _truckService = TruckService();


  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _extractWardDetails();
    _loadTruckData(widget.provinceId, widget.districtId, widget.councilId);
    _listenToDriverLocation(widget.provinceId, widget.districtId, widget.councilId);

  }

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

  // Modify _loadTruckData to pass truckDetails to _loadBinData
  void _loadTruckData(String provinceId, String districtId, String councilId) {
    try {
      _truckService
          .fetchTruckDetailsRealtime(wardName, provinceId, districtId, councilId)
          .listen((truckDetails) async {
        if (truckDetails.isNotEmpty) {
          // Pass truck details to _loadBinData to extract bin data
          await _loadBinDataRealtime(truckDetails); // Extract bin data
          await _loadTruckMovements(truckDetails);

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
            // print("Monday: $mondayReferenceData");

            if (mondayReferenceData != null && mondayReferenceData is Map<String, dynamic>) {
              var collectionPointRefs = mondayReferenceData['collection_point_ref'];
              // print('COllection:$collectionPointRefs ');

              if (collectionPointRefs is List) {
                for (var collectionPointRef in collectionPointRefs) {
                  if (collectionPointRef is DocumentReference) {
                    collectionPointRef.snapshots().listen((collectionPointSnapshot) async {
                      if (collectionPointSnapshot.exists) {
                        var collectionPointData = collectionPointSnapshot.data();

                        if (collectionPointData is Map<String, dynamic>) {
                          String roadName = collectionPointData['road_name'] ?? 'Unknown';
                          var binLocationRef = collectionPointRef.collection('bin locations');
                          // print('Road: $roadName');

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
                                  // print("Road Name: $roadName");

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



  Future<void> _loadTruckMovements(List<Map<String, dynamic>> truckDetails) async {
    // Clear existing truck routes
    // setState(() {
    //   _truckRoutes.clear();
    // });

    for (var truck in truckDetails) {
      var truckId = truck['truck_id'];
      var schedule = truck['schedule'];

      if (schedule != null) {
        var nonRecycling = schedule['non_recycling'];
        if (nonRecycling != null && nonRecycling.isNotEmpty) {
          for (var nonRecyclingMap in nonRecycling) {
            var mondayReferenceData = nonRecyclingMap['Monday_reference_data'];
            print("Monday: $mondayReferenceData");

            if (mondayReferenceData != null && mondayReferenceData is Map<String, dynamic>) {
              // Extract route_geopoints
              List<dynamic>? routeGeopoints = mondayReferenceData['route_geopoints'] as List<dynamic>?;
              if (routeGeopoints != null) {
                setState(() {
                  _truckRoutes.add({
                    'id': truckId,
                    'route': routeGeopoints.map((dynamic item) {
                      if (item is GeoPoint) {
                        // If the item is already a GeoPoint, convert it to LatLng
                        return LatLng(item.latitude, item.longitude);
                      } else {
                        // Handle the case where the item is not a GeoPoint (optional)
                        return const LatLng(0.0, 0.0);  // Default location or handle as necessary
                      }
                    }).toList(),
                    'route_id': mondayReferenceData['route_id'], // Add route_id to truck route data
                  });
                });
              }

              // Fetch and update bin locations (existing logic remains)
              var collectionPointRefs = mondayReferenceData['collection_point_ref'];
              if (collectionPointRefs is List) {
                for (var collectionPointRef in collectionPointRefs) {
                  if (collectionPointRef is DocumentReference) {
                    collectionPointRef.snapshots().listen((collectionPointSnapshot) async {
                      if (collectionPointSnapshot.exists) {
                        var collectionPointData = collectionPointSnapshot.data();
                        if (collectionPointData is Map<String, dynamic>) {
                          var collectionPointId = collectionPointData['road_name']; // Add collection point ID

                          var binLocationRef = collectionPointRef.collection('bin locations');
                          binLocationRef.snapshots().listen((binLocationSnapshot) {
                            for (var doc in binLocationSnapshot.docs) {
                              var binLocationData = doc.data();
                              var location = binLocationData['location'];
                              if (location != null && location is GeoPoint) {
                                setState(() {
                                  _binTrackLocations.add({
                                    'latitude': location.latitude,
                                    'longitude': location.longitude,
                                    'status': binLocationData['status'],
                                    'bin_id': binLocationData['bin_id'],
                                    'route_id': mondayReferenceData['route_id'], // Add route_id to each bin
                                    'collection_point_id': collectionPointId,   // Add collection_point_id to each bin
                                  });
                                });
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

    _startTruckRoute();
  }

  double calculateBearing(LatLng start, LatLng end) {
    double startLat = start.latitude * (math.pi / 180);
    double startLng = start.longitude * (math.pi / 180);
    double endLat = end.latitude * (math.pi / 180);
    double endLng = end.longitude * (math.pi / 180);

    double deltaLng = endLng - startLng;

    double x = math.sin(deltaLng) * math.cos(endLat);
    double y = math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(deltaLng);

    double bearing = math.atan2(x, y) * (180 / math.pi);
    return (bearing + 360) % 360; // Normalize to 0-360 degrees
  }


  void _animateTruckMovement(String truckId, List<LatLng> route) async {
    BitmapDescriptor truckIcon = await _getTruckIcon();

    print('Route Length: ${route.length}');

    for (int i = 0; i < route.length; i++) {
      LatLng currentPoint = route[i];
      LatLng? nextPoint = i < route.length - 1 ? route[i + 1] : null;
      double? bearing = nextPoint != null ? calculateBearing(currentPoint, nextPoint) : null;

      // Adjust bearing for alignment
      double adjustedBearing = (bearing ?? 0) + 20 % 360;

      // Update marker position and rotation
      setState(() {
        _markers.removeWhere((m) => m.markerId.value == truckId);
        _markers.add(
          Marker(
            markerId: MarkerId(truckId),
            position: currentPoint,
            icon: truckIcon,
            rotation: adjustedBearing, // Rotate truck marker to match heading
            anchor: const Offset(0.5, 0.5),
          ),
        );
      });

      // Animate camera for every 3rd point to reduce jitter
      if (i % 3 == 0) {
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentPoint,
              zoom: 17, // Adjust zoom level as needed
              bearing: bearing ?? 0, // Rotate the camera to align with the truck's heading
              tilt: 45, // Tilt for a 3D perspective
            ),
          ),
        );
      }

      print('BinLocation saved data: $_binTrackLocations');

      // Check if the truck is at a stop point
      bool isStopPoint = _binTrackLocations.any((bin) =>
      bin['latitude'] == currentPoint.latitude &&
          bin['longitude'] == currentPoint.longitude);

      if (isStopPoint) {
        print("Updating database");

        // Find the bin to update
        var binToUpdate = _binTrackLocations.firstWhere(
              (bin) =>
          bin['latitude'] == currentPoint.latitude &&
              bin['longitude'] == currentPoint.longitude,
          orElse: () => <String, dynamic>{}, // Return an empty map if not found
        );

        if (binToUpdate.isNotEmpty) {
          var binId = binToUpdate['bin_id'];
          var routeId = binToUpdate['route_id'];
          var collectionPointId = binToUpdate['collection_point_id'];

          // Update truck status to "empty"
          await _truckService.updateTruckDetails(
            truckId: truckId,
            binId: binId,
            routeId: routeId,
            collectionPointId: collectionPointId,
            updatedData: {"status": "Full"},
          );
        }

        await Future.delayed(const Duration(seconds: 40)); // Stop for 40 seconds
      } else {
        await Future.delayed(const Duration(seconds: 1)); // Simulate movement delay
      }
    }

    // Handle the last point
    print("Reached last point: ${route.last}");
  }


  void _startTruckRoute() async {

    for (var truckRoute in _truckRoutes) {
      String truckId = truckRoute['id'];
      List<LatLng> route = truckRoute['route'];
      print("Loaded truck: $truckRoute");
      _animateTruckMovement(truckId, route);
    }
  }


  Future<BitmapDescriptor> _getTruckIcon() async {
    return BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(100, 100)),
      'assets/images/truck1.png',
    );
  }


    void _listenToDriverLocation(String provinceId, String districtId, String councilId) {
    try {
      _truckService
          .fetchTruckDetailsRealtime(wardName, provinceId, districtId, councilId)
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
      // Remove existing driver marker if any
      _markers.removeWhere((marker) => marker.markerId.value == 'driver_marker');

      // Add the new driver marker to the map
      _markers.add(Marker(
        markerId: MarkerId('driver_marker'),
        position: driverLatLng,
        infoWindow: InfoWindow(
          title: 'Driver Location',
          snippet: 'Latitude: ${driverLatLng.latitude}, Longitude: ${driverLatLng.longitude}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));

      // Animate camera to show driver's location
      googleMapController.animateCamera(
        CameraUpdate.newLatLngZoom(driverLatLng, 17),
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
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _defaultCenter,
          zoom: 17,
        ),
        markers: _markers,
        polygons: polygons,
        onMapCreated: (controller) {
          googleMapController = controller;
          if (_isStyleLoaded) {
            googleMapController.setMapStyle(_mapStyle);
          }
        },
      ),
    );
  }
}


