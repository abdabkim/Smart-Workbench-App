import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:smart_workbench_app/providers/user_provider.dart';
import 'package:smart_workbench_app/screens/automationscreen.dart';
import 'package:smart_workbench_app/screens/categoryselectionscreen.dart';
import 'package:smart_workbench_app/screens/controlpanelscreen.dart';
import 'package:smart_workbench_app/screens/dashboardscreen.dart';
import 'package:smart_workbench_app/screens/loginscreen.dart';
import 'package:smart_workbench_app/screens/monitoringscreen.dart';
import 'package:smart_workbench_app/screens/settingsscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:smart_workbench_app/screens/signupscreen.dart';

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
  Future<void> getUser()async{
    try{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    final response = await http.get(
      Uri.parse('http://192.168.0.6:8000/auth/getuser'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );
    Map<String, dynamic> data = jsonDecode(response.body);

    Provider.of<User>(context,listen: false).update(data);
  }catch (error) {
      print('ERROR $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
      );
     }
    }

  @override
  void initState() {
   WidgetsBinding.instance.addPostFrameCallback((_){
     getUser();
   }); // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Hello ${Provider.of<User>(context).getName()}'), // Display welcome message
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
              builder: (context) => const CategorySelectionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
