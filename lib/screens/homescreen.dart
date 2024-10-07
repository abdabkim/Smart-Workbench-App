import 'package:flutter/material.dart';
import 'package:smart_workbench_app/screens/adddevicesscreen.dart';
import 'package:smart_workbench_app/screens/automationscreen.dart';
import 'package:smart_workbench_app/screens/controlpanelscreen.dart';
import 'package:smart_workbench_app/screens/dashboardscreen.dart';
import 'package:smart_workbench_app/screens/loginscreen.dart';
import 'package:smart_workbench_app/screens/monitoringscreen.dart';
import 'package:smart_workbench_app/screens/settingsscreen.dart';
import 'package:smart_workbench_app/screens/signupscreen.dart';
//import 'dashboardscreen.dart';
//import 'controlpanelscreen.dart';
//import 'monitoringscreen.dart';
//import 'automationscreen.dart';
//import 'settingsscreen.dart';
//import 'loginscreen.dart';
//import 'signupscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const DashboardScreen(),
    const ControlPanelScreen(),
    const MonitoringScreen(),
    const AutomationScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Smart WorkBench'),
        actions: [
          if (_selectedIndex == 0) // Only show on Dashboard
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ),
            ),
          if (_selectedIndex == 0) // Only show on Dashboard
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              ),
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.brown,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png', // Replace with actual logo URL
                    height: 70,
                    width: 70,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'WorkBench Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.control_camera),
              title: const Text('Control Panel'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.monitor_heart),
              title: const Text('Monitoring'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.device_hub),
              title: const Text('Automation'),
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                _onItemTapped(4);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.brown, // Fallback color
            child: Image.asset(
              'assets/bg.jpg',
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fill,
            ),
          ),
          _pages[_selectedIndex]
        ],
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
              builder: (context) => const AddDevicesScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


