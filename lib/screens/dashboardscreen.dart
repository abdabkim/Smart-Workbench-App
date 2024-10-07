import 'package:flutter/material.dart';
import 'package:smart_workbench_app/screens/smartplugscreen.dart';
import 'package:smart_workbench_app/screens/smartworkspacescreen.dart';
import 'package:smart_workbench_app/widget/devicecard.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Home!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade800,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  DeviceCard(
                    title: 'Smart Workspace',
                    icon: Icons.work_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SmartWorkspaceScreen(),
                        ),
                      );
                    },
                  ),
                  DeviceCard(
                    title: 'Smart Plug',
                    icon: Icons.power,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SmartPlugScreen(),
                        ),
                      );
                    },
                  ),
                  DeviceCard(
                    title: 'Thermostat',
                    icon: Icons.thermostat_outlined,
                    onTap: () {
                      // Add navigation or functionality
                    },
                  ),
                  DeviceCard(
                    title: 'Security Camera',
                    icon: Icons.videocam_outlined,
                    onTap: () {
                      // Add navigation or functionality
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