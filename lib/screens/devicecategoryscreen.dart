import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_workbench_app/screens/devicestatusscreen.dart';

class DeviceAreaInputScreen extends StatefulWidget {
  final String deviceType;

  const DeviceAreaInputScreen({Key? key, required this.deviceType}) : super(key: key);

  @override
  State<DeviceAreaInputScreen> createState() => _DeviceAreaInputScreenState();
}

class _DeviceAreaInputScreenState extends State<DeviceAreaInputScreen> {
  final TextEditingController _areaController = TextEditingController();
  final String baseUrl = 'http://192.168.0.10:8000/device';
  String? authToken;

  @override
  void initState() {
    super.initState();
    _getAuthToken();
  }

  Future<void> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('token');
    });
    print('Auth Token Retrieved: ${authToken != null}');
  }

  // Predefined areas list
  final List<String> predefinedAreas = [
    'Workshop',
    'Garage',
    'Basement',
    'Shed',
  ];

  String _determineCategory() {
    if (widget.deviceType.toLowerCase().contains('saw')) {
      return 'Saw';
    } else if (widget.deviceType.toLowerCase().contains('drill')) {
      return 'Drill';
    } else {
      return 'Other';
    }
  }

  Future<void> _sendToBackend(String area) async {
    if (authToken == null) {
      print('No auth token available');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication error. Please log in again.')),
        );
      }
      return;
    }

    try {
      print('Sending to backend - Device: ${widget.deviceType}, Area: $area');
      final response = await http.post(
        Uri.parse('$baseUrl/new'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'deviceName': widget.deviceType,
          'category': _determineCategory(),
          'area': area,
          'status': false
        }),
      );

      print('Backend response status: ${response.statusCode}');
      print('Backend response body: ${response.body}');

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Device saved successfully')),
          );
          // Navigate to status screen after successful save
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceStatusScreen(
                deviceType: widget.deviceType,
                area: area,
                category: _determineCategory(),
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to save device: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving device: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save device: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Device Area'),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Where will you place the ${widget.deviceType}?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 24),
                // Predefined area buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: predefinedAreas.map((area) =>
                      ElevatedButton(
                        onPressed: () => _sendToBackend(area),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade50,
                          foregroundColor: Colors.brown,
                        ),
                        child: Text(area),
                      ),
                  ).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Or enter a custom area:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _areaController,
                  decoration: InputDecoration(
                    labelText: 'Custom Area Name',
                    hintText: 'e.g., Kitchen, Office',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _sendToBackend(value.trim());
                      _areaController.clear();
                    }
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_areaController.text.isNotEmpty) {
                      _sendToBackend(_areaController.text.trim());
                      _areaController.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter an area')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Save Device'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }
}