import 'package:flutter/material.dart';
import 'package:smart_workbench_app/screens/devicecategoryscreen.dart';
import 'package:smart_workbench_app/widget/devicetypecard.dart';

class AddDevicesScreen extends StatelessWidget {
  const AddDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Device'),
        backgroundColor: Colors.brown.shade50,
      ),
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Device Type',
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
                        title: 'Smart Phone Charger',
                        icon: Icons.power,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceAreaInputScreen(deviceType: 'Smart Phone Charger'),
                            ),
                          ); // Navigate to Smart Plug setup
                        },
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                      DeviceTypeCard(
                        title: 'Wireless Charger',
                        icon: Icons.power,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceAreaInputScreen(deviceType: 'Smart Phone Charger'),
                            ),
                          );  // Navigate to Smart Plug setup
                        },
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                      DeviceTypeCard(
                        title: 'Light',
                        icon: Icons.thermostat,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceAreaInputScreen(deviceType: 'Smart Phone Charger'),
                            ),
                          ); // Navigate to Thermostat setup
                        },
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                      DeviceTypeCard(
                        title: 'Security Camera',
                        icon: Icons.videocam,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceAreaInputScreen(deviceType: 'Smart Phone Charger'),
                            ),
                          );  // Navigate to Security Camera setup
                        },
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                      DeviceTypeCard(
                        title: 'Table Saw',
                        icon: Icons.view_week,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceAreaInputScreen(deviceType: 'Smart Phone Charger'),
                            ),
                          ); // Navigate to Smart Light setup
                        },
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                      DeviceTypeCard(
                        title: 'Miter Saw',
                        icon: Icons.cut,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceAreaInputScreen(deviceType: 'Smart Phone Charger'),
                            ),
                          );  // Navigate to Security Camera setup
                        },
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                      DeviceTypeCard(
                        title: 'Circular Saw',
                        icon: Icons.circle,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceAreaInputScreen(deviceType: 'Smart Phone Charger'),
                            ),
                          ); // Navigate to Security Camera setup
                        },
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                      DeviceTypeCard(
                        title: 'Planer',
                        icon: Icons.horizontal_rule,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceAreaInputScreen(deviceType: 'Smart Phone Charger'),
                            ),
                          );  // Navigate to Security Camera setup
                        },
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                      DeviceTypeCard(
                        title: 'Router',
                        icon: Icons.router,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceAreaInputScreen(deviceType: 'Smart Phone Charger'),
                            ),
                          );  // Navigate to Security Camera setup
                        },
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                      DeviceTypeCard(
                        title: 'Drill Press',
                        icon: Icons.build,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceAreaInputScreen(deviceType: 'Smart Phone Charger'),
                            ),
                          ); // Navigate to Security Camera setup
                        },
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                      DeviceTypeCard(
                        title: 'Belt Sander',
                        icon: Icons.drag_indicator,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceAreaInputScreen(deviceType: 'Smart Phone Charger'),
                            ),
                          ); // Navigate to Security Camera setup
                        },
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                      DeviceTypeCard(
                        title: 'Joiner',
                        icon: Icons.unfold_more,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceAreaInputScreen(deviceType: 'Smart Phone Charger'),
                            ),
                          ); // Navigate to Security Camera setup
                        },
                        backgroundColor: Colors.brown,
                        textColor: Colors.white,
                      ),
                      DeviceTypeCard(
                        title: 'Jigsaw',
                        icon: Icons.show_chart,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceAreaInputScreen(deviceType: 'Smart Phone Charger'),
                            ),
                          );// Navigate to Security Camera setup
                        },
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
}
