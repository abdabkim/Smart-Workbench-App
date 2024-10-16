import 'package:flutter/material.dart';
import 'package:smart_workbench_app/screens/device_status_screen.dart';

class DeviceAreaInputScreen extends StatefulWidget {
  final String deviceType;

  const DeviceAreaInputScreen({Key? key, required this.deviceType}) : super(key: key);

  @override
  _DeviceAreaInputScreenState createState() => _DeviceAreaInputScreenState();
}

class _DeviceAreaInputScreenState extends State<DeviceAreaInputScreen> {
  final TextEditingController _areaController = TextEditingController();

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Device Area'),
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
                  'Enter the area for ${widget.deviceType}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _areaController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Kitchen, Garage, Office',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_areaController.text.isNotEmpty) {
                      _navigateToDeviceStatus(context, _areaController.text);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter an area')),
                      );
                    }
                  },
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDeviceStatus(BuildContext context, String area) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceStatusScreen(
          deviceType: widget.deviceType,
          area: area,
        ),
      ),
    );
  }
}