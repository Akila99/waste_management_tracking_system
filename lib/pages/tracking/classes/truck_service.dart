import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class TruckService {

  // Global variables to store selected IDs
  String? provinceId;
  String? districtId;
  String? councilId;
  String? wardName;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> fetchTruckDetailsRealtime(String wardName,
      String provinceId, String districtId, String councilId) {
    // Store the provided IDs in global variables
    this.wardName = wardName;
    this.provinceId = provinceId;
    this.districtId = districtId;
    this.councilId = councilId;
    try {
      // Return a stream of truck details
      return FirebaseFirestore.instance
          .collection('province')
          .doc(provinceId)
          .collection('districts')
          .doc(districtId)
          .collection('council')
          .doc(councilId)
          .collection('ward')
          .where('ward_name', isEqualTo: wardName)
          .snapshots()
          .asyncExpand((wardSnapshot) async* {
        if (wardSnapshot.docs.isEmpty) {
          debugPrint("No ward found for: $wardName");
          yield [];
          return;
        }

        var wardDoc = wardSnapshot.docs.first;
        var trucksCollection = wardDoc.reference.collection('trucks');

        yield* trucksCollection.snapshots().map((truckSnapshot) async {
          var truckDetails = <Map<String, dynamic>>[];

          for (var truckDoc in truckSnapshot.docs) {
            Map<String, dynamic> truckData = {};

            truckData['truck_id'] = truckDoc['truck_id'] ?? "No truck ID";
            truckData['time'] = truckDoc['time'] ?? "No time info";

            var startingPoint = truckDoc['starting_point'];
            if (startingPoint is GeoPoint) {
              truckData['starting_point'] = {
                'latitude': startingPoint.latitude,
                'longitude': startingPoint.longitude
              };
            }
            // Add drivers array to truck data
            var drivers = truckDoc['drivers'];
            if (drivers != null && drivers is List) {
              truckData['drivers'] = drivers;
            } else {
              truckData['drivers'] = [];
            }


            // Fetch schedule
            var schedule = truckDoc['schedule'];
            if (schedule != null) {
              truckData['schedule'] = {};

              // Handle non_recycling array
              var nonRecycling = schedule['non_recycling'];
              if (nonRecycling != null && nonRecycling.isNotEmpty) {
                truckData['schedule']['non_recycling'] = [];
                for (var nonRecyclingItem in nonRecycling) {
                  if (nonRecyclingItem is Map<String, dynamic>) {
                    var mondayArray = nonRecyclingItem['Monday'];
                    if (mondayArray != null && mondayArray is List) {
                      for (var reference in mondayArray) {
                        if (reference is DocumentReference) {
                          // Fetch details for the reference
                          var mondaySnapshot = await reference.get();
                          if (mondaySnapshot.exists) {
                            truckData['schedule']['non_recycling'].add({
                              'Monday_reference_data': mondaySnapshot.data(),
                            });
                          }
                        }
                      }
                    }
                  }
                }
              }

              // Handle perishable array
              var perishable = schedule['perishable'];
              if (perishable != null && perishable.isNotEmpty) {
                truckData['schedule']['perishable'] = perishable;
              } else {
                truckData['schedule']['perishable'] = [];
              }
            } else {
              truckData['schedule'] = "No schedule data available";
            }

            truckDetails.add(truckData);
          }

          return truckDetails;
        }).asyncMap((event) => event); // To flatten async mapping
      });
    } catch (e) {
      debugPrint("Error fetching truck details in real-time: $e");
      return const Stream.empty();
    }
  }

  Future<void> updateTruckDetails({
    required String truckId,
    required Map<String, dynamic> updatedData,
    required String binId,
    required String routeId,
    required String collectionPointId,
  }) async {
    try {
      // Validate essential IDs
      if (provinceId == null || districtId == null || councilId == null || wardName == null) {
        throw Exception("Required IDs are missing. Set them before updating.");
      }

      // Fetch the specific ward document
      final wardQuerySnapshot = await _firestore
          .collection('province')
          .doc(provinceId)
          .collection('districts')
          .doc(districtId)
          .collection('council')
          .doc(councilId)
          .collection('ward')
          .where('ward_name', isEqualTo: wardName)
          .get();

      if (wardQuerySnapshot.docs.isEmpty) {
        throw Exception("Ward not found for: $wardName");
      }

      // Get the first ward document reference
      final wardDocRef = wardQuerySnapshot.docs.first.reference;

      // Reference to the 'trucks' collection
      final trucksCollectionRef = wardDocRef.collection('trucks');

      // Query for the truck document by `truck_id`
      final truckQuerySnapshot = await trucksCollectionRef
          .where('truck_id', isEqualTo: truckId)
          .get();

      if (truckQuerySnapshot.docs.isEmpty) {
        throw Exception("Truck with truck_id: $truckId not found in the specified ward.");
      }

      // Get the specific truck document reference
      final truckDocRef = truckQuerySnapshot.docs.first.reference;

      // Fetch the schedule for non-recycling collection points
      final schedule = (await truckDocRef.get()).data()?['schedule'];
      if (schedule == null || schedule['non_recycling'] == null) {
        throw Exception("No schedule found for Truck ID: $truckId");
      }

      // Process the non-recycling schedule
      final nonRecycling = schedule['non_recycling'];
      for (var nonRecyclingMap in nonRecycling) {
        var mondayReferenceData = nonRecyclingMap['Monday'];

        if (mondayReferenceData != null && mondayReferenceData is List) {
          for (var collectionPointRef in mondayReferenceData) {
            if (collectionPointRef is DocumentReference) {
              final collectionPointSnapshot = await collectionPointRef.get();

              if (collectionPointSnapshot.exists) {
                var data = collectionPointSnapshot.data() as Map<String, dynamic>;

                // Check for matching route_id
                if (data['route_id'] == routeId) {
                  print("Matching route_id found: ${data['route_id']}");

                  // Get references to collection points
                  var collectionPointRefs = data['collection_point_ref'];
                  if (collectionPointRefs is List) {
                    for (var ref in collectionPointRefs) {
                      if (ref is DocumentReference) {
                        final refSnapshot = await ref.get();

                        if (refSnapshot.exists) {
                          var refData = refSnapshot.data() as Map<String, dynamic>;

                          // Check for matching road_name
                          if (refData['road_name'] == collectionPointId) {
                            print("Matching road_name found: ${refData['road_name']}");

                            // Reference to the 'bin locations' collection
                            var binLocationRef = ref.collection('bin locations');
                            print('binLocationRef: $binLocationRef');

                            // Fetch all bin location documents
                            final binLocationSnapshot = await binLocationRef.get();

                            for (var binDoc in binLocationSnapshot.docs) {
                              print('Bin Doc: $binDoc');

                              // Match the bin_id
                              if (binDoc['bin_id'] == binId) {
                                // Update the bin document
                                await binDoc.reference.update({
                                  ...updatedData,
                                  'status': 'Full', // or any other status you wish to set
                                });
                                debugPrint("Bin with bin_id: $binId updated successfully.");
                              }
                            }
                          } else {
                            print("No matching road_name found for route_id: $routeId.");
                          }
                        }
                      }
                    }
                  }
                } else {
                  print("No matching route_id found.");
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error updating bin locations: $e");
      throw Exception("Failed to update bin locations: $e");
    }
  }
}