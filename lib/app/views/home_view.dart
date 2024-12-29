// lib/app/views/home_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vendors = [
      {
        'id': '21370ef6-95aa-44f2-9207-243918d177b7',
        'kitchenName': 'Smor Bakery',
        'kitchenAddress': 'Alathur',
      },
      // Add more vendors as needed
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurants')),
      body: ListView.builder(
        itemCount: vendors.length,
        itemBuilder: (_, index) {
          final vendor = vendors[index];
          return ListTile(
            title: Text(vendor['kitchenName'] ?? 'No Name'),
            subtitle: Text(vendor['kitchenAddress'] ?? 'No Address'),
            onTap: () {
              // Navigate to restaurant details with vendorId
              Get.toNamed('/restaurant-details', arguments: {
                'vendorId': vendor['id'],
              });
            },
          );
        },
      ),
    );
  }
}
