import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class BinDataLoader {
  // Global variables to store selected IDs
  String? provinceId;
  String? districtId;
  String? councilId;
  String? wardName;



  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> fetchBinDetailsRealtime(String wardName,
      String provinceId, String districtId, String councilId,   bool mounted) {
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
        if (!mounted) return; // Ensure that the widget is still mounted

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



}