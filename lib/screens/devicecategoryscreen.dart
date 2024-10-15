import 'package:flutter/material.dart';
import 'package:smart_workbench_app/widget/devicetypecard.dart';
import 'package:smart_workbench_app/screens/device_status_screen.dart';

class DeviceCategoryScreen extends StatelessWidget {
  final String deviceType;

  const DeviceCategoryScreen({Key? key, required this.deviceType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Category for $deviceType'),
        backgroundColor: Colors.brown.shade50,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Device Category',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      DeviceTypeCard(
                        title: 'Workspace',
                        icon: Icons.work,
                        onTap: () => _navigateToDeviceStatus(context, 'Workspace'),
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                      DeviceTypeCard(
                        title: 'Living Room',
                        icon: Icons.living,
                        onTap: () => _navigateToDeviceStatus(context, 'Living Room'),
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                      DeviceTypeCard(
                        title: 'Bedroom',
                        icon: Icons.bed,
                        onTap: () => _navigateToDeviceStatus(context, 'Bedroom'),
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                      DeviceTypeCard(
                        title: 'Outdoor',
                        icon: Icons.outdoor_grill,
                        onTap: () => _navigateToDeviceStatus(context, 'Outdoor'),
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                      DeviceTypeCard(
                        title: 'Garage',
                        icon: Icons.garage,
                        onTap: () => _navigateToDeviceStatus(context, 'Garage'),
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDeviceStatus(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceStatusScreen(
          deviceType: deviceType,
          category: category,
        ),
      ),
    );
  }
}