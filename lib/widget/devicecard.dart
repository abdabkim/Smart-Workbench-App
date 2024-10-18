import 'package:flutter/material.dart';




class DeviceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const DeviceCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.brown,
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}
