import 'package:flutter/material.dart';

class DeviceTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;  // Change to Color instead of MaterialColor
  final Color textColor;

  const DeviceTypeCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.backgroundColor,  // Ensure these are required
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,  // Set the background color of the card
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 48, color: textColor),  // Set the icon color
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,  // Set the text color
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: textColor),  // Set the trailing icon color
        onTap: onTap,
      ),
    );
  }
}
