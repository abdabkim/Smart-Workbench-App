import 'package:flutter/material.dart';

class WorkspaceControlCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const WorkspaceControlCard({
    Key? key,
    required this.title,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.brown,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(
                title,
                style: const TextStyle(fontSize: 18, color: Colors.white)
            ),
          ],
        ),
      ),
    );
  }
}