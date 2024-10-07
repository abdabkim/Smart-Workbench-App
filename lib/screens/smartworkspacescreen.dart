import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:smart_workbench_app/widget/workspacecontrolcard.dart';



class SmartWorkspaceScreen extends StatelessWidget {
  const SmartWorkspaceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Workspace'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Workspace Controls',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    WorkspaceControlCard(
                        title: 'Desk Height', icon: Icons.height),
                    WorkspaceControlCard(
                        title: 'Lighting', icon: Icons.lightbulb),
                    WorkspaceControlCard(
                        title: 'Temperature', icon: Icons.thermostat),
                    WorkspaceControlCard(title: 'Air Quality', icon: Icons.air),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
