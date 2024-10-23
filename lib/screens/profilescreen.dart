import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:smart_workbench_app/screens/loginscreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  String userEmail = '';
  String jobRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final email = prefs.getString('email');

    if (email != null) {
      // Try to fetch user data from backend
      try {
        final response = await http.get(
          Uri.parse('http://192.168.0.6:8000/auth/user-profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);
          setState(() {
            userName = userData['name'] ?? email.split('@')[0];
            userEmail = email;
            jobRole = userData['jobRole'] ?? 'Not specified';
          });
        } else {
          // If backend request fails, use stored data
          setState(() {
            userName = email.split('@')[0];
            userEmail = email;
            jobRole = 'Not specified';
          });
        }
      } catch (e) {
        // If there's an error, use stored data
        setState(() {
          userName = email.split('@')[0];
          userEmail = email;
          jobRole = 'Not specified';
        });
      }
    }
  }

  Future<void> _showLogoutConfirmation() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _handleLogout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');



      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully logged out')),
      );

      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/profile_picture.jpg'),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.brown,
                              radius: 18,
                              child: IconButton(
                                icon: Icon(Icons.camera_alt,
                                    size: 18, color: Colors.white),
                                onPressed: () {
                                  // Implement photo upload logic
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'User Information',
                    [
                      _buildInfoTile('Name', userName),
                      _buildInfoTile('Job Role', jobRole),
                      _buildInfoTile('Email', userEmail),
                    ],
                  ),
                  _buildSection(
                    'Workbench Preferences',
                    [
                      _buildPreferenceTile('Tool Preferences', Icons.build),
                      _buildPreferenceTile('Saved Workflows', Icons.article),
                      _buildPreferenceTile('Settings', Icons.settings),
                    ],
                  ),
                  _buildSection(
                    'Workstation Status',
                    [
                      _buildStatusTile('Desk Height', '75 cm', Icons.height),
                      _buildStatusTile('Lighting', 'On - 80%', Icons.lightbulb),
                      _buildStatusTile('Temperature', '22°C', Icons.thermostat),
                      _buildStatusTile('Air Quality', 'Good', Icons.air),
                    ],
                  ),
                  _buildSection(
                    'App Settings',
                    [
                      _buildSettingsTile('Account Settings', Icons.manage_accounts),
                      _buildSettingsTile('Privacy Settings', Icons.privacy_tip),
                      _buildLogoutButton(context),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.brown)),
      trailing: Text(value, style: TextStyle(color: Colors.brown)),
    );
  }

  Widget _buildPreferenceTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown),
      title: Text(title, style: TextStyle(color: Colors.brown)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.brown),
      onTap: () {
        // Navigate to respective preference screen
      },
    );
  }

  Widget _buildStatusTile(String title, String status, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown),
      title: Text(title, style: TextStyle(color: Colors.brown)),
      trailing: Text(status, style: TextStyle(color: Colors.brown)),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown),
      title: Text(title, style: TextStyle(color: Colors.brown)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.brown),
      onTap: () {
        // Navigate to respective settings screen
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Logout',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        onPressed: _showLogoutConfirmation,
      ),
    );
  }
}