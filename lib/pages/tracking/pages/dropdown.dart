import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_management_tracking/pages/tracking/pages/live_trcking_screen.dart';
import 'map_screen.dart';
import 'package:dropdown_search/dropdown_search.dart';

class ProvinceDistrictDropdown extends StatefulWidget {
  @override
  _ProvinceDistrictDropdownState createState() => _ProvinceDistrictDropdownState();
}

class _ProvinceDistrictDropdownState extends State<ProvinceDistrictDropdown> {
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedCouncil;
  String? selectedWard;

  List<DropdownMenuItem<String>> provinceItems = [];
  List<DropdownMenuItem<String>> districtItems = [];
  List<DropdownMenuItem<String>> councilItems = [];
  List<DropdownMenuItem<String>> wardItems = [];

  @override
  void initState() {
    super.initState();
    fetchProvinces(); // Fetch provinces on initialization
  }

  Future<void> fetchProvinces() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('province').get();
      final items = snapshot.docs.map((doc) {
        var province = doc.data() as Map<String, dynamic>;
        return DropdownMenuItem<String>(
          value: doc.id, // Use document ID as the value
          child: Text(province['province_name'] ?? 'Unknown Province'),
        );
      }).toList();

      if (items.isEmpty) {
        items.add(
          const DropdownMenuItem<String>(
            value: null,
            child: Text('No Data Available', style: TextStyle(color: Colors.grey)),
          ),
        );
      }

      setState(() {
        provinceItems = items;
      });
    } catch (e) {
      print('Error fetching provinces: $e');
    }
  }

  Future<void> fetchDistricts(String provinceId) async {
    if (provinceId.isEmpty) {
      print('Province ID is missing.');
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('province')
          .doc(provinceId)
          .collection('districts')
          .get();

      final items = snapshot.docs.map((doc) {
        var district = doc.data() as Map<String, dynamic>;
        return DropdownMenuItem<String>(
          value: doc.id,
          child: Text(district['district_name'] ?? 'Unknown District'),
        );
      }).toList();

      if (items.isEmpty) {
        items.add(
          const DropdownMenuItem<String>(
            value: null,
            child: Text('No Data Available', style: TextStyle(color: Colors.grey)),
          ),
        );
      }

      setState(() {
        districtItems = items;
        councilItems = [];
        wardItems = [];
        selectedDistrict = null;
        selectedCouncil = null;
        selectedWard = null;
      });
    } catch (e) {
      print('Error fetching districts: $e');
    }
  }

  Future<void> fetchCouncils(String provinceId, String districtId) async {
    if (provinceId.isEmpty || districtId.isEmpty) {
      print('Province ID or District ID is missing.');
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('province')
          .doc(provinceId)
          .collection('districts')
          .doc(districtId)
          .collection('council')
          .get();

      final items = snapshot.docs.map((doc) {
        var council = doc.data() as Map<String, dynamic>;
        return DropdownMenuItem<String>(
          value: doc.id,
          child: Text(council['council_name'] ?? 'Unknown Council'),
        );
      }).toList();

      if (items.isEmpty) {
        items.add(
          const DropdownMenuItem<String>(
            value: null,
            child: Text('No Data Available', style: TextStyle(color: Colors.grey)),
          ),
        );
      }

      setState(() {
        councilItems = items;
        wardItems = [];
        selectedCouncil = null;
        selectedWard = null;
      });
    } catch (e) {
      print('Error fetching councils: $e');
    }
  }

  Future<void> fetchWards(String provinceId, String districtId, String councilId) async {
    if (provinceId.isEmpty || districtId.isEmpty || councilId.isEmpty) {
      print('Province ID, District ID, or Council ID is missing.');
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('province')
          .doc(provinceId)
          .collection('districts')
          .doc(districtId)
          .collection('council')
          .doc(councilId)
          .collection('ward')
          .get();

      final items = snapshot.docs.map((doc) {
        var ward = doc.data() as Map<String, dynamic>;
        return DropdownMenuItem<String>(
          value: doc.id,
          child: Text(ward['ward_name'] ?? 'Unknown Ward'),
        );
      }).toList();

      if (items.isEmpty) {
        items.add(
          const DropdownMenuItem<String>(
            value: null,
            child: Text('No Data Available', style: TextStyle(color: Colors.grey)),
          ),
        );
      }

      setState(() {
        wardItems = items;
        selectedWard = null;
      });
    } catch (e) {
      print('Error fetching wards: $e');
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Small box with message above dropdowns
  //           Container(
  //             decoration: BoxDecoration(
  //               border: Border.all(color: Colors.green, width: 2),
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             padding: const EdgeInsets.all(16.0),
  //             margin: const EdgeInsets.only(bottom: 20), // Adds space below the box
  //             child: const Text(
  //               "Track the garbage collection vehicle for your area. Stay updated on its real-time location and never miss a pickup again! 🚛",
  //               style: TextStyle(
  //                 fontSize: 15,
  //                 fontWeight: FontWeight.w400,
  //                 color: Colors.black87,
  //               ),
  //             ),
  //           ),
  //
  //           // Province Dropdown
  //           Text('Select Province:', style: TextStyle(fontSize: 16)),
  //           DropdownButton<String>(
  //             hint: Text('Select a Province'),
  //             value: selectedProvince,
  //             isExpanded: true,
  //             items: provinceItems,
  //             onChanged: (value) {
  //               setState(() {
  //                 selectedProvince = value;
  //                 districtItems = [];
  //                 councilItems = [];
  //                 wardItems = [];
  //                 selectedDistrict = null;
  //                 selectedCouncil = null;
  //                 selectedWard = null;
  //               });
  //               if (value != null) {
  //                 fetchDistricts(value);
  //               }
  //             },
  //           ),
  //           SizedBox(height: 20),
  //
  //           // District Dropdown
  //           Text('Select District:', style: TextStyle(fontSize: 16)),
  //           DropdownButton<String>(
  //             hint: Text('Select a District'),
  //             value: selectedDistrict,
  //             isExpanded: true,
  //             items: districtItems,
  //             onChanged: (value) {
  //               setState(() {
  //                 selectedDistrict = value;
  //                 councilItems = [];
  //                 wardItems = [];
  //                 selectedCouncil = null;
  //                 selectedWard = null;
  //               });
  //               if (value != null && selectedProvince != null) {
  //                 fetchCouncils(selectedProvince!, value);
  //               }
  //             },
  //           ),
  //           SizedBox(height: 20),
  //
  //           // Council Dropdown
  //           Text('Select Council:', style: TextStyle(fontSize: 16)),
  //           DropdownButton<String>(
  //             hint: Text('Select a Council'),
  //             value: selectedCouncil,
  //             isExpanded: true,
  //             items: councilItems,
  //             onChanged: (value) {
  //               setState(() {
  //                 selectedCouncil = value;
  //                 wardItems = [];
  //                 selectedWard = null;
  //               });
  //               if (value != null && selectedProvince != null && selectedDistrict != null) {
  //                 fetchWards(selectedProvince!, selectedDistrict!, value);
  //               }
  //             },
  //           ),
  //           SizedBox(height: 20),
  //
  //           // Ward Dropdown
  //           Text('Select Ward:', style: TextStyle(fontSize: 16)),
  //           DropdownButton<String>(
  //             hint: Text('Select a Ward'),
  //             value: selectedWard,
  //             isExpanded: true,
  //             items: wardItems,
  //             onChanged: (value) {
  //               setState(() {
  //                 selectedWard = value;
  //               });
  //             },
  //           ),
  //           SizedBox(height: 20), // Adds space between dropdowns and button
  //
  //           // Track Button
  //           Center(
  //             child: Column(
  //               children: [
  //                 // Existing Track Button
  //                 ElevatedButton(
  //                   onPressed: () async {
  //                     if (selectedProvince != null &&
  //                         selectedDistrict != null &&
  //                         selectedCouncil != null &&
  //                         selectedWard != null) {
  //                       // Fetch specific details based on the selected inputs
  //                       try {
  //                         DocumentSnapshot wardDetailsSnapshot = await FirebaseFirestore
  //                             .instance
  //                             .collection('province')
  //                             .doc(selectedProvince) // Province ID
  //                             .collection('districts')
  //                             .doc(selectedDistrict) // District ID
  //                             .collection('council')
  //                             .doc(selectedCouncil) // Council ID
  //                             .collection('ward')
  //                             .doc(selectedWard) // Ward ID
  //                             .get();
  //
  //                         if (wardDetailsSnapshot.exists) {
  //                           Map<String, dynamic> wardDetails =
  //                           wardDetailsSnapshot.data() as Map<String, dynamic>;
  //
  //                           Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (context) => MapScreen(
  //                                 wardDetails: wardDetails,
  //                                 provinceId: selectedProvince!,
  //                                 districtId: selectedDistrict!,
  //                                 councilId: selectedCouncil!,
  //                               ),
  //                             ),
  //                           );
  //                         } else {
  //                           print("No details found for the selected ward.");
  //                         }
  //                       } catch (e) {
  //                         print("Error fetching ward details: $e");
  //                       }
  //                     } else {
  //                       print("Please select all dropdown options before tracking.");
  //                     }
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.green,
  //                     padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                   child: Text(
  //                     'Track',
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 16,
  //                     ),
  //                   ),
  //                 ),
  //
  //                 const SizedBox(height: 20), // Spacer between buttons
  //
  //                 // New Live Tracking Button
  //                 ElevatedButton(
  //                   onPressed: () async {
  //                     if (selectedProvince != null &&
  //                         selectedDistrict != null &&
  //                         selectedCouncil != null &&
  //                         selectedWard != null) {
  //                       try {
  //                         DocumentSnapshot wardDetailsSnapshot = await FirebaseFirestore
  //                             .instance
  //                             .collection('province')
  //                             .doc(selectedProvince) // Province ID
  //                             .collection('districts')
  //                             .doc(selectedDistrict) // District ID
  //                             .collection('council')
  //                             .doc(selectedCouncil) // Council ID
  //                             .collection('ward')
  //                             .doc(selectedWard) // Ward ID
  //                             .get();
  //
  //                         if (wardDetailsSnapshot.exists) {
  //                           Map<String, dynamic> wardDetails =
  //                           wardDetailsSnapshot.data() as Map<String, dynamic>;
  //
  //                           // Navigate to the live tracking screen
  //                           Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (context) => LiveTrackingScreen(
  //                                 wardDetails: wardDetails,
  //                                 provinceId: selectedProvince!,
  //                                 districtId: selectedDistrict!,
  //                                 councilId: selectedCouncil!,
  //                               ),
  //                             ),
  //                           );
  //                         } else {
  //                           print("No details found for the selected ward.");
  //                         }
  //                       } catch (e) {
  //                         print("Error fetching ward details for live tracking: $e");
  //                       }
  //                     } else {
  //                       print("Please select all dropdown options before starting live tracking.");
  //                     }
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.green,
  //                     padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                   child: Text(
  //                     'Live Tracking',
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 16,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Small box with message above dropdowns
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 20), // Adds space below the box
                  child: const Text(
                    "Track the garbage collection vehicle for your area. Stay updated on its real-time location and never miss a pickup again! 🚛",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Province Dropdown
                Text('Select Province:', style: TextStyle(fontSize: 16)),
                DropdownButton<String>(
                  hint: Text('Select a Province'),
                  value: selectedProvince,
                  isExpanded: true,
                  items: provinceItems,
                  onChanged: (value) {
                    setState(() {
                      selectedProvince = value;
                      districtItems = [];
                      councilItems = [];
                      wardItems = [];
                      selectedDistrict = null;
                      selectedCouncil = null;
                      selectedWard = null;
                    });
                    if (value != null) {
                      fetchDistricts(value);
                    }
                  },
                ),
                SizedBox(height: 20),

                // District Dropdown
                Text('Select District:', style: TextStyle(fontSize: 16)),
                DropdownButton<String>(
                  hint: Text('Select a District'),
                  value: selectedDistrict,
                  isExpanded: true,
                  items: districtItems,
                  onChanged: (value) {
                    setState(() {
                      selectedDistrict = value;
                      councilItems = [];
                      wardItems = [];
                      selectedCouncil = null;
                      selectedWard = null;
                    });
                    if (value != null && selectedProvince != null) {
                      fetchCouncils(selectedProvince!, value);
                    }
                  },
                ),
                SizedBox(height: 20),

                // Council Dropdown
                Text('Select Council:', style: TextStyle(fontSize: 16)),
                DropdownButton<String>(
                  hint: Text('Select a Council'),
                  value: selectedCouncil,
                  isExpanded: true,
                  items: councilItems,
                  onChanged: (value) {
                    setState(() {
                      selectedCouncil = value;
                      wardItems = [];
                      selectedWard = null;
                    });
                    if (value != null && selectedProvince != null && selectedDistrict != null) {
                      fetchWards(selectedProvince!, selectedDistrict!, value);
                    }
                  },
                ),
                SizedBox(height: 20),

                // Ward Dropdown
                Text('Select Ward:', style: TextStyle(fontSize: 16)),
                DropdownButton<String>(
                  hint: Text('Select a Ward'),
                  value: selectedWard,
                  isExpanded: true,
                  items: wardItems,
                  onChanged: (value) {
                    setState(() {
                      selectedWard = value;
                    });
                  },
                ),
                SizedBox(height: 20), // Adds space between dropdowns and button

                // Track Button
                Center(
                  child: Column(
                    children: [
                      // Existing Track Button
                      ElevatedButton(
                        onPressed: () async {
                          if (selectedProvince != null &&
                              selectedDistrict != null &&
                              selectedCouncil != null &&
                              selectedWard != null) {
                            // Fetch specific details based on the selected inputs
                            try {
                              DocumentSnapshot wardDetailsSnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('province')
                                  .doc(selectedProvince) // Province ID
                                  .collection('districts')
                                  .doc(selectedDistrict) // District ID
                                  .collection('council')
                                  .doc(selectedCouncil) // Council ID
                                  .collection('ward')
                                  .doc(selectedWard) // Ward ID
                                  .get();

                              if (wardDetailsSnapshot.exists) {
                                Map<String, dynamic> wardDetails =
                                wardDetailsSnapshot.data() as Map<String, dynamic>;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MapScreen(
                                      wardDetails: wardDetails,
                                      provinceId: selectedProvince!,
                                      districtId: selectedDistrict!,
                                      councilId: selectedCouncil!,
                                    ),
                                  ),
                                );
                              } else {
                                print("No details found for the selected ward.");
                              }
                            } catch (e) {
                              print("Error fetching ward details: $e");
                            }
                          } else {
                            print("Please select all dropdown options before tracking.");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Track',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20), // Spacer between buttons

                      // New Live Tracking Button
                      ElevatedButton(
                        onPressed: () async {
                          if (selectedProvince != null &&
                              selectedDistrict != null &&
                              selectedCouncil != null &&
                              selectedWard != null) {
                            try {
                              DocumentSnapshot wardDetailsSnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('province')
                                  .doc(selectedProvince) // Province ID
                                  .collection('districts')
                                  .doc(selectedDistrict) // District ID
                                  .collection('council')
                                  .doc(selectedCouncil) // Council ID
                                  .collection('ward')
                                  .doc(selectedWard) // Ward ID
                                  .get();

                              if (wardDetailsSnapshot.exists) {
                                Map<String, dynamic> wardDetails =
                                wardDetailsSnapshot.data() as Map<String, dynamic>;

                                // Navigate to the live tracking screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LiveTrackingScreen(
                                      wardDetails: wardDetails,
                                      provinceId: selectedProvince!,
                                      districtId: selectedDistrict!,
                                      councilId: selectedCouncil!,
                                    ),
                                  ),
                                );
                              } else {
                                print("No details found for the selected ward.");
                              }
                            } catch (e) {
                              print("Error fetching ward details for live tracking: $e");
                            }
                          } else {
                            print("Please select all dropdown options before starting live tracking.");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Live Tracking',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}









