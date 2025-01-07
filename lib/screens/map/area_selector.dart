import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_management_tracking/screens/map/map_screen_version2.dart';

class AreaSelector extends StatefulWidget {
  const AreaSelector({super.key});

  @override
  State<AreaSelector> createState() => _AreaSelectorState();
}

class _AreaSelectorState extends State<AreaSelector> {
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
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('province').get();

      final items = snapshot.docs.map((doc) {
        var province = doc.data() as Map<String, dynamic>;
        return DropdownMenuItem<String>(
          value: doc.id,
          child: Text(province['province_name'] ?? 'Unknown Province'),
        );
      }).toList();

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

  Future<void> fetchWards(String provinceId, String districtId,
      String councilId) async {
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

      setState(() {
        wardItems = items;
        selectedWard = null;
      });
    } catch (e) {
      print('Error fetching wards: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Area'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Province:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Select a Province'),
                      value: selectedProvince,
                      items: provinceItems,
                      onChanged: (value) {
                        setState(() {
                          selectedProvince = value;
                          selectedDistrict = null;
                          selectedCouncil = null;
                          selectedWard = null;
                        });
                        if (value != null) {
                          fetchDistricts(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Select District:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Select a District'),
                      value: selectedDistrict,
                      items: districtItems,
                      onChanged: (value) {
                        setState(() {
                          selectedDistrict = value;
                          selectedCouncil = null;
                          selectedWard = null;
                        });
                        if (value != null && selectedProvince != null) {
                          fetchCouncils(selectedProvince!, value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Council:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Select a Council'),
                      value: selectedCouncil,
                      items: councilItems,
                      onChanged: (value) {
                        setState(() {
                          selectedCouncil = value;
                          selectedWard = null;
                        });
                        if (value != null &&
                            selectedProvince != null &&
                            selectedDistrict != null) {
                          fetchWards(selectedProvince!, selectedDistrict!, value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Ward:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Select a Ward'),
                      value: selectedWard,
                      items: wardItems,
                      onChanged: (value) {
                        setState(() {
                          selectedWard = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (selectedProvince != null &&
                    selectedDistrict != null &&
                    selectedCouncil != null &&
                    selectedWard != null) {
                  try {
                    DocumentSnapshot wardDetailsSnapshot = await FirebaseFirestore.instance
                        .collection('province')
                        .doc(selectedProvince)
                        .collection('districts')
                        .doc(selectedDistrict)
                        .collection('council')
                        .doc(selectedCouncil)
                        .collection('ward')
                        .doc(selectedWard)
                        .get();

                    if (wardDetailsSnapshot.exists) {
                      Map<String, dynamic> wardDetails =
                      wardDetailsSnapshot.data() as Map<String, dynamic>;

                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreen(
                              wardDetails: wardDetails,
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select all areas')),
                  );
                }
              },
              child: const Text('View Map'),
            ),
          ],
        ),
      ),
    );
  }
}