import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataRetrival extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Remove the 'const' keyword here
  DataRetrival({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provinces'),
      ),
      body: StreamBuilder(
        // Stream to listen to changes in the 'province' collection
        stream: firestore.collection('province').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data found.'));
          }

          // Get the documents from the 'province' collection
          final provinces = snapshot.data!.docs;

          return ListView.builder(
            itemCount: provinces.length,
            itemBuilder: (context, index) {
              var province = provinces[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(province['province_name'] ?? 'Unknown Province'),
                subtitle: Text('ID: ${provinces[index].id}'),
                onTap: () {
                  // On tap, navigate to the next screen to show districts
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => DistrictScreen(provinceId: provinces[index].id),
                  //   ),
                  // );
                },
              );
            },
          );
        },
      ),
    );
  }
}

