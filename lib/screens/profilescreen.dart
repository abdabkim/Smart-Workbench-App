import 'package:flutter/material.dart';
import 'package:smart_workbench_app/screens/homescreen.dart';
import 'package:smart_workbench_app/screens/welcomescreen.dart';



class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image covering the entire screen
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
                  // Profile Picture
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
                  // User Information
                  _buildSection(
                    'User Information',
                    [
                      _buildInfoTile('Name', 'John Doe'),
                      _buildInfoTile('Job Role', 'Senior Engineer'),
                      _buildInfoTile('Email', 'john.doe@techcorp.com'),
                    ],
                  ),
                  // Workbench Preferences
                  _buildSection(
                    'Workbench Preferences',
                    [
                      _buildPreferenceTile('Tool Preferences', Icons.build),
                      _buildPreferenceTile(
                          'Saved Workflows',
                          Icons
                              .article), // Changed from Icons.workflow to Icons.article
                      _buildPreferenceTile('Settings', Icons.settings),
                    ],
                  ),
                  // Workstation Status
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
                      _buildSettingsTile(
                          'Account Settings', Icons.manage_accounts),
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
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
          );
        },
      ),
    );
  }
}
