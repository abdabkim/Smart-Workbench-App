import 'package:flutter/material.dart';
import 'package:smart_workbench_app/screens/controlpanelscreen.dart';
import 'package:smart_workbench_app/screens/smartplugsetupscreen.dart';
import 'package:smart_workbench_app/screens/smartworkspacescreen.dart';
import 'package:smart_workbench_app/widget/devicecard.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
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
                        title: 'Control Panel',
                        icon: Icons.dashboard_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ControlPanelScreen(
                                deviceType: 'Control Panel',
                                category: 'Power Device',
                                area: 'Workshop',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          tooltip: 'Add New Device',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PlugInScreen(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}