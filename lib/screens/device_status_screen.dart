import 'package:flutter/material.dart';

class DeviceStatusScreen extends StatefulWidget {
  final String deviceType;
  final String category;

  const DeviceStatusScreen({
    Key? key,
    required this.deviceType,
    required this.category,
  }) : super(key: key);

  @override
  _DeviceStatusScreenState createState() => _DeviceStatusScreenState();
}

class _DeviceStatusScreenState extends State<DeviceStatusScreen> {
  bool isDeviceOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Status'),
        backgroundColor: Colors.brown.shade50,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category: ${widget.category}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  color: Colors.brown.shade50,
                  child: ListTile(
                    title: Text(widget.deviceType),
                    subtitle: Text('Status: ${isDeviceOn ? 'On' : 'Off'}'),
                    trailing: Switch(
                      value: isDeviceOn,
                      onChanged: (value) {
                        setState(() {
                          isDeviceOn = value;
                        });
                      },
                      activeColor: Colors.green,
                      inactiveTrackColor: Colors.red.shade200,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}