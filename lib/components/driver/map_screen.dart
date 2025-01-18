import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import 'package:waste_management_tracking/pages/tracking/classes/truck_service.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';



// class MapScreen extends StatefulWidget {
//   final Map<String, dynamic> wardDetails;
//
//   const MapScreen({required this.wardDetails, Key? key}) : super(key: key);
//
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _defaultCenter = const LatLng(6.902495, 79.854713);
  late String _mapStyle = '';
  bool _isStyleLoaded = false;
  late GoogleMapController googleMapController;
  Set<Marker> _markers = {};
  Set<Circle> circles = {};
  Set<Polygon> polygons = HashSet<Polygon>();
  List<LatLng> wardCoordinates = [];
  StreamSubscription<Position>? positionStream;
  String wardName = "Bambalapitiya";
  String provinceId = "s7Xku26b4zyxxWXOFV3A";
  String districtId ="1";
  String councilId = "1";
  final List<Map<String, dynamic>> _binLocations = [];


  final TruckService _truckService = TruckService();

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _requestLocationPermission();
    _ensureLocationServiceEnabled();
    // _extractWardDetails();
    // _addWardPolygon();
    _startLiveTracking();
    _loadTruckData();

  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint("Location permissions are denied");
    }
  }

  Future<void> _ensureLocationServiceEnabled() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      debugPrint("Location services are disabled.");
    }
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
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

  // void _extractWardDetails() {
  //   wardName = widget.wardDetails['ward_name'] ?? "Unknown Ward";
  //
  //   if (widget.wardDetails['boundary'] != null &&
  //       widget.wardDetails['boundary']['coordinates'] != null) {
  //     final List<dynamic> coordinates = widget.wardDetails['boundary']['coordinates'];
  //
  //     wardCoordinates = coordinates.map((coord) {
  //       if (coord is GeoPoint) {
  //         return LatLng(coord.latitude, coord.longitude);
  //       } else {
  //         return LatLng(0.0, 0.0);
  //       }
  //     }).toList();
  //   }
  // }

  void _loadTruckData() {
    try {
      _truckService
          .fetchTruckDetailsRealtime(wardName, provinceId, districtId, councilId)
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

  void _addWardPolygon() {
    if (wardCoordinates.isNotEmpty) {
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
            fillColor: Colors.green.withOpacity(0.1),
            geodesic: true,
          ),
        );
      });
    }
  }

  // void _startLiveTracking() {
  //   positionStream = Geolocator.getPositionStream(
  //     locationSettings: const LocationSettings(
  //       accuracy: LocationAccuracy.high,
  //       distanceFilter: 10, // Update location every 10 meters
  //     ),
  //   ).listen((Position position) {
  //     if (googleMapController != null) {
  //       _updateUserLocation(position);
  //     } else {
  //       debugPrint("Map is not ready for live tracking.");
  //     }
  //   });
  // }
  //
  // void _updateUserLocation(Position position) async {
  //   if (googleMapController == null) {
  //     debugPrint("GoogleMapController is not initialized yet.");
  //     return;
  //   }
  //
  //   final LatLng newPosition = LatLng(position.latitude, position.longitude);
  //
  //   BitmapDescriptor truckIcon = await _getTruckIcon();
  //
  //   final Marker userMarker = Marker(
  //     markerId: const MarkerId("user_location"),
  //     position: newPosition,
  //     icon: truckIcon,
  //     infoWindow: const InfoWindow(title: "Truck Location"),
  //   );
  //
  //   // Update markers without overwriting all markers
  //   setState(() {
  //     _markers.removeWhere((marker) => marker.markerId == const MarkerId("user_location"));
  //     _markers.add(userMarker);
  //   });
  //
  //   googleMapController.animateCamera(CameraUpdate.newLatLng(newPosition));
  // }

  void _startLiveTracking() {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update location every 10 meters
      ),
    ).listen((Position position) {
      if (googleMapController != null) {
        _updateUserLocation(position);
      } else {
        debugPrint("Map is not ready for live tracking.");
      }
    });
  }

  void _updateUserLocation(Position position) async {
    if (googleMapController == null) {
      debugPrint("GoogleMapController is not initialized yet.");
      return;
    }

    final LatLng newPosition = LatLng(position.latitude, position.longitude);

    BitmapDescriptor truckIcon = await _getTruckIcon();

    final Marker userMarker = Marker(
      markerId: const MarkerId("user_location"),
      position: newPosition,
      icon: truckIcon,
      infoWindow: const InfoWindow(title: "Truck Location"),
    );

    // Update markers without overwriting all markers
    setState(() {
      _markers.removeWhere((marker) => marker.markerId == const MarkerId("user_location"));
      _markers.add(userMarker);
    });

    googleMapController.animateCamera(CameraUpdate.newLatLng(newPosition));

    // Save the location to Firestore
    _storeLocationInFirestore(position);
  }

  void _storeLocationInFirestore(Position position) {
    final driverId = "driver_uid"; // Replace with dynamic driver ID if necessary

    // Create a GeoPoint using the position's latitude and longitude
    final GeoPoint geoPoint = GeoPoint(position.latitude, position.longitude);

    // Update Firestore with the GeoPoint
    FirebaseFirestore.instance.collection('drivers').doc(driverId).set({
      'truck_live_location': geoPoint,
      // Use a GeoPoint field
    }, SetOptions(merge: true)).then((_) {
      debugPrint("Location updated in Firestore for driver $driverId.");
    }).catchError((error) {
      debugPrint("Failed to update location in Firestore: $error");
    });
  }


  Future<BitmapDescriptor> _getTruckIcon() async {
    try {
      return await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(60, 60)),
        'assets/images/truck.png',
      );
    } catch (e) {
      debugPrint("Error in _getTruckIcon: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wardName),
        backgroundColor: Colors.lightGreen,
      ),
      body: _isStyleLoaded
          ? Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
              googleMapController.setMapStyle(_mapStyle);
            },


            initialCameraPosition: CameraPosition(
              target: wardCoordinates.isNotEmpty
                  ? wardCoordinates.first
                  : _defaultCenter,
              zoom: 17.0,

            ),

            myLocationEnabled: true, // Disables the blue dot location
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            circles: circles,
            markers: _markers,
            polygons: polygons,

          ),
          // Positioned button here
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                try {
                  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                  if (!serviceEnabled) {
                    debugPrint("Location services are disabled.");
                    return;
                  }

                  Position position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );
                  LatLng currentPosition = LatLng(position.latitude, position.longitude);

                  googleMapController.animateCamera(
                    CameraUpdate.newLatLngZoom(currentPosition, 17.0),
                  );

                  // Add a marker for the user's location if desired
                  setState(() {
                    _markers.add(
                      Marker(
                        markerId: const MarkerId("current_location"),
                        position: currentPosition,
                        infoWindow: const InfoWindow(title: "You Are Here"),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed),
                      ),
                    );
                  });
                } catch (e) {
                  debugPrint("Error fetching location: $e");
                }
              },
              backgroundColor: Colors.white70,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),

        ],
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}


