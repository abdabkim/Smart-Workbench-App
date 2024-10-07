import 'package:flutter/material.dart';

import 'package:smart_workbench_app/widget/devicetypecard.dart';



class AddDevicesScreen extends StatelessWidget {
  const AddDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Device'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Device Type',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  DeviceTypeCard(
                    title: 'Smart Plug',
                    icon: Icons.power,
                    onTap: () {
                      // Navigate to Smart Plug setup
                    },
                  ),
                  DeviceTypeCard(
                    title: 'Thermostat',
                    icon: Icons.thermostat,
                    onTap: () {
                      // Navigate to Thermostat setup
                    },
                  ),
                  DeviceTypeCard(
                    title: 'Security Camera',
                    icon: Icons.videocam,
                    onTap: () {
                      // Navigate to Security Camera setup
                    },
                  ),
                  DeviceTypeCard(
                    title: 'Smart Light',
                    icon: Icons.lightbulb,
                    onTap: () {
                      // Navigate to Smart Light setup
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}