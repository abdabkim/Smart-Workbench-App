import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class SmartPlugScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Plug'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Plug Controls',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              SizedBox(height: 16),
              Card(
                color: Colors.brown,
                child: SwitchListTile(
                  title: Text('Power', style: TextStyle(color: Colors.white)),
                  value: true, // Replace with actual state
                  onChanged: (bool value) {
                    // Implement power toggle logic
                  },
                ),
              ),
              SizedBox(height: 8),
              Card(
                color: Colors.brown,
                child: ListTile(
                  title: Text('Power Consumption',
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text('120W',
                      style: TextStyle(
                          color: Colors.white70)), // Replace with actual value
                  trailing: Icon(Icons.show_chart, color: Colors.white),
                  onTap: () {
                    // Navigate to detailed power consumption view
                  },
                ),
              ),
              SizedBox(height: 8),
              Card(
                color: Colors.brown,
                child: ListTile(
                  title:
                  Text('Schedule', style: TextStyle(color: Colors.white)),
                  subtitle: Text('2 active schedules',
                      style: TextStyle(
                          color: Colors.white70)), // Replace with actual count
                  trailing: Icon(Icons.schedule, color: Colors.white),
                  onTap: () {
                    // Navigate to schedule management
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
