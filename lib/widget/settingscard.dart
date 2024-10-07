import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const SettingsCard({
    Key? key,
    required this.title,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.brown,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.white),
        title: Text(title,
            style: const TextStyle(fontSize: 18, color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: onTap ??
                () {
              // Navigate to specific setting screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('$title settings page not implemented yet')),
              );
            },
      ),
    );
  }
}
