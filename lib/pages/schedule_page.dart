import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Align(alignment: Alignment.centerLeft,
            child: const Text(
              "Schedule",
              style: TextStyle(fontSize: 20),
            )
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align everything to the left
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: const Text(
                  "You can check your schedule here. Based on the area you live, we provide a detailed schedule and a route map for authorized users!📅",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(height: 20), // Add some spacing before the dropdowns

              // Province Dropdown with Prompt
              const Text("Select your province:", style: TextStyle(fontSize: 14)),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("province").snapshots(),
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

                  List<DropdownMenuItem<String>> provinceItems = provinces.map((province) {
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
                const Text("Select your district:", style: TextStyle(fontSize: 14)),
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
                        child: Text("No districts found for this province"),
                      );
                    }

                    List<DropdownMenuItem<String>> districtItems = districts.map((district) {
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
                const Text("Select your council:", style: TextStyle(fontSize: 14)),
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
                        child: Text("No councils found for this district"),
                      );
                    }

                    List<DropdownMenuItem<String>> councilItems = councils.map((council) {
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
                const Text("Select your ward:", style: TextStyle(fontSize: 14)),
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
                        child: Text("No wards found for this council"),
                      );
                    }

                    List<DropdownMenuItem<String>> wardItems = wards.map((ward) {
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
      ),
    );
  }

  void _showTimetableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Timetable"),
        content: Table(
          border: TableBorder.all(color: Colors.grey),
          children: [
            for (int rowIndex = 0; rowIndex < 3; rowIndex++)
              TableRow(
                children: [
                  for (int colIndex = 0; colIndex < 5; colIndex++)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        colIndex < 4
                            ? "link database"
                            : "image${rowIndex + 1}",
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
          ],
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
