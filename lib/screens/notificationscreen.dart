import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.brown,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            _buildNotificationTile(
              'Desk Height Adjusted',
              'Your desk height has been set to 80 cm.',
              Icons.height,
            ),
            _buildNotificationTile(
              'Lighting Changed',
              'Workspace lighting has been adjusted to 70%.',
              Icons.lightbulb,
            ),
            _buildNotificationTile(
              'Temperature Alert',
              'Room temperature is now 24°C.',
              Icons.thermostat,
            ),
            _buildNotificationTile(
              'Air Quality Update',
              'Air quality in your workspace is excellent.',
              Icons.air,
            ),
            _buildNotificationTile(
              'New Workflow Saved',
              'Your latest workflow "Project X" has been saved.',
              Icons.article,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(String title, String subtitle, IconData icon) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white.withOpacity(0.8),
      child: ListTile(
        leading: Icon(icon, color: Colors.brown),
        title: Text(title,
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.brown)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.brown),
        onTap: () {
          // Handle notification tap
        },
      ),
    );
  }
}