import 'package:flutter/material.dart';

class DeviceTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;

  const DeviceTypeCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 48, color: textColor),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,  // Set the text color
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: textColor),
        onTap: onTap,
      ),
    );
  }
}
