import 'package:flutter/material.dart';



class AutomationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AutomationCard(
      {Key? key,
        required this.title,
        required this.subtitle,
        required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.brown,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 48, color: Colors.white),
        title: Text(title,
            style: const TextStyle(fontSize: 18, color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: Switch(
          value: true,
          onChanged: (bool value) {
            // Toggle automation logic here
          },
        ),
      ),
    );
  }
}
