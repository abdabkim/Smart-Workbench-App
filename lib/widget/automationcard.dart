import 'package:flutter/material.dart';

class AutomationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String deviceName;
  final bool actionIsOn;
  final IconData icon;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const AutomationCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.deviceName,
    required this.actionIsOn,
    required this.icon,
    required this.onDelete,
    required this.onEdit,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 8.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: actionIsOn ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              const SizedBox(width: 16.0),
              // Icon
              Icon(
                icon,
                size: 32.0,
                color: Colors.brown,
              ),
              const SizedBox(width: 16.0),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          Icons.devices,
                          size: 16.0,
                          color: Colors.brown[300],
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          deviceName,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.brown[700],
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: actionIsOn ? Colors.green[100] : Colors.red[100],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            actionIsOn ? 'ON' : 'OFF',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: actionIsOn ? Colors.green[700] : Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Toggle button
              IconButton(
                icon: Icon(
                  actionIsOn ? Icons.power_settings_new : Icons.power_off,
                  color: actionIsOn ? Colors.green : Colors.red,
                ),
                onPressed: onToggle,
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.brown[300],
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}