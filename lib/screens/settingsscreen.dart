import 'package:flutter/material.dart';
import 'package:smart_workbench_app/screens/notificationscreen.dart';
import 'package:smart_workbench_app/screens/profilescreen.dart';
import 'package:smart_workbench_app/widget/settingscard.dart';



class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade800),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      SettingsCard(
                        title: 'Account',
                        icon: Icons.person,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen()),
                          );
                        },
                      ),
                      SettingsCard(
                        title: 'Notifications',
                        icon: Icons.notifications,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationsScreen()),
                          );
                        },
                      ),
                      SettingsCard(title: 'Privacy', icon: Icons.lock),
                      SettingsCard(title: 'Help & Support', icon: Icons.help),
                      SettingsCard(title: 'About', icon: Icons.info),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
