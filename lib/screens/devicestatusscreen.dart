import 'package:flutter/material.dart';

class DeviceStatusScreen extends StatefulWidget {
  final String deviceType;
  final String category;
  final String area;

  const DeviceStatusScreen({
    Key? key,
    required this.deviceType,
    required this.category,
    required this.area,
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
        title: Text('Tool Status'),
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
                SizedBox(height: 8),
                Text(
                  'Tool: ${widget.deviceType}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.brown,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Area: ${widget.area}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.brown,
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  color: Colors.brown.shade50,
                  child: ListTile(
                    title: Text('Power Status'),
                    subtitle: Text(isDeviceOn ? 'On' : 'Off'),
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