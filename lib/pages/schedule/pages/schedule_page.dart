import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  _SchedulePageState createState() =>
      _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedCouncil;
  String? selectedWard;


  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
  }

  Future<void> _checkLoggedInUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final userWard = userData['ward'];
        final userProvince = userData['province'];
        final userDistrict = userData['district'];
        final userCouncil = userData['council'];

        setState(() {
          selectedWard = userWard;
          selectedProvince = userProvince;
          selectedDistrict = userDistrict;
          selectedCouncil = userCouncil;
        });

        if (userWard != null) {
          _showTimetableDialog();
        }
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top-left "Schedule" heading
                  Text(
                    "Schedule",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Green outlined box with text
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      "You can check your schedule here. Based on the area you live, we provide a detailed schedule and a route map for authorized users! 📅",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Province Dropdown
                  const Text(
                      "Select your province:", style: TextStyle(fontSize: 14)),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection("province")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text("Error: ${snapshot.error}"),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final provinces = snapshot.data?.docs ?? [];
                      if (provinces.isEmpty) {
                        return const Center(
                          child: Text("No provinces found"),
                        );
                      }

                      List<DropdownMenuItem<String>> provinceItems = provinces
                          .map((province) {
                        return DropdownMenuItem(
                          value: province.id,
                          child: Text(province['province_name']),
                        );
                      }).toList();

                      return DropdownWrapper(
                        title: "province",
                        value: selectedProvince,
                        items: provinceItems,
                        onChanged: (value) {
                          setState(() {
                            selectedProvince = value;
                            selectedDistrict = null;
                            selectedCouncil = null;
                            selectedWard = null;
                          });
                        },
                      );
                    },
                  ),

                  // District Dropdown with Prompt
                  if (selectedProvince != null) ...[
                    const SizedBox(height: 10),
                    const Text("Select your district:",
                        style: TextStyle(fontSize: 14)),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("province")
                          .doc(selectedProvince)
                          .collection("districts")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final districts = snapshot.data?.docs ?? [];
                        if (districts.isEmpty) {
                          return const Center(
                            child: Text("Under Construction. Coming soon!!"),
                          );
                        }

                        List<DropdownMenuItem<String>> districtItems = districts
                            .map((district) {
                          return DropdownMenuItem(
                            value: district.id,
                            child: Text(district['district_name']),
                          );
                        }).toList();

                        return DropdownWrapper(
                          title: "district",
                          value: selectedDistrict,
                          items: districtItems,
                          onChanged: (value) {
                            setState(() {
                              selectedDistrict = value;
                              selectedCouncil = null;
                              selectedWard = null;
                            });
                          },
                        );
                      },
                    ),
                  ],

                  // Council Dropdown with Prompt
                  if (selectedDistrict != null) ...[
                    const SizedBox(height: 10),
                    const Text(
                        "Select your council:", style: TextStyle(fontSize: 14)),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("province")
                          .doc(selectedProvince)
                          .collection("districts")
                          .doc(selectedDistrict)
                          .collection("council")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final councils = snapshot.data?.docs ?? [];
                        if (councils.isEmpty) {
                          return const Center(
                            child: Text("Under Construction. Coming soon!!"),
                          );
                        }

                        List<DropdownMenuItem<String>> councilItems = councils
                            .map((council) {
                          return DropdownMenuItem(
                            value: council.id,
                            child: Text(council['council_name']),
                          );
                        }).toList();

                        return DropdownWrapper(
                          title: "council",
                          value: selectedCouncil,
                          items: councilItems,
                          onChanged: (value) {
                            setState(() {
                              selectedCouncil = value;
                              selectedWard = null;
                            });
                          },
                        );
                      },
                    ),
                  ],

                  // Ward Dropdown with Prompt
                  if (selectedCouncil != null) ...[
                    const SizedBox(height: 10),
                    const Text(
                        "Select your ward:", style: TextStyle(fontSize: 14)),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("province")
                          .doc(selectedProvince)
                          .collection("districts")
                          .doc(selectedDistrict)
                          .collection("council")
                          .doc(selectedCouncil)
                          .collection("ward")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final wards = snapshot.data?.docs ?? [];
                        if (wards.isEmpty) {
                          return const Center(
                            child: Text("Under Construction. Coming soon!!"),
                          );
                        }

                        List<DropdownMenuItem<String>> wardItems = wards.map((
                            ward) {
                          return DropdownMenuItem(
                            value: ward.id,
                            child: Text(ward['ward_name']),
                          );
                        }).toList();

                        return DropdownWrapper(
                          title: "ward",
                          value: selectedWard,
                          items: wardItems,
                          onChanged: (value) {
                            setState(() {
                              selectedWard = value;
                            });
                            _showTimetableDialog();
                          },
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          )
      ),
    );
  }

  void _showTimetableDialog() async {
    if (selectedWard == null) {
      return;
    }

    // Fetch routes from Firebase Firestore
    final routesSnapshot = await FirebaseFirestore.instance
        .collection("province")
        .doc(selectedProvince)
        .collection("districts")
        .doc(selectedDistrict)
        .collection("council")
        .doc(selectedCouncil)
        .collection("ward")
        .doc(selectedWard)
        .collection("routes")
        .get();

    final routes = routesSnapshot.docs;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Timetable"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: routes.map((routeDoc) {
              final routeData = routeDoc.data();
              final routeName = routeData['name'] ?? 'Unnamed Route';
              final startTime = routeData['start'] ?? 'N/A';
              final endTime = routeData['end'] ?? 'N/A';
              final routeMap = routeData['map'] ?? null; // Map path or URL

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route Name
                    Text(
                      "Route: $routeName",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Time
                    Text(
                      "Start time: $startTime",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "End time: $endTime",
                      style: const TextStyle(fontSize: 16),
                    ),

                    // Route Map Link
                    if (routeMap != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showRouteMapPopup(routeMap),
                        child: const Text(
                          "Route Map",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }


// Function to show the route map in a popup
  void _showRouteMapPopup(String path) {
    final isLocalAsset = path.startsWith('assets/');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: InteractiveViewer(
          child: isLocalAsset
              ? Image.asset(path, fit: BoxFit.contain)
              : Image.network(path, fit: BoxFit.contain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

// Widget for Dropdown Styling
class DropdownWrapper extends StatelessWidget {
  final String title;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?) onChanged;

  const DropdownWrapper({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        height: 40,
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(10), // Rounder dropdowns
        ),
        child: DropdownButton<String>(
          isExpanded: true,
          underline: const SizedBox(),
          hint: Text(title),
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
