import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SmartPlugScreen extends StatefulWidget {
  final String deviceType;
  final String category;
  final String area;

  const SmartPlugScreen({
    super.key,
    required this.deviceType,
    required this.category,
    required this.area,
  });

  @override
  State<SmartPlugScreen> createState() => _SmartPlugScreenState();
}

class _SmartPlugScreenState extends State<SmartPlugScreen> {
  final String baseUrl = 'http://192.168.0.6:8000/device';
  List<dynamic> devices = [];
  bool isLoading = true;
  String? authToken;

  @override
  void initState() {
    super.initState();
    _getAuthTokenAndFetchDevices();
  }

  Future<void> _getAuthTokenAndFetchDevices() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('token');
    print('Auth Token: $authToken');
    await fetchDevices();
  }

  Future<void> fetchDevices() async {
    if (authToken == null) {
      print('No auth token available');
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      print('Fetching devices...');
      final response = await http.get(
        Uri.parse('$baseUrl/retrieveall'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (mounted) {
          setState(() {
            devices = responseData['devices'] ?? [];
            isLoading = false;
          });
        }
        print('Devices loaded: ${devices.length}');
      } else {
        throw Exception('Failed to load devices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching devices: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateDeviceStatus(String deviceId, bool newStatus) async {
    if (authToken == null) return;

    try {
      print('Updating status for device $deviceId to $newStatus');

      // Mirror exactly what's working in DeviceStatusScreen
      final url = Uri.parse('http://192.168.0.6:8000/device/update/$deviceId');
      print('Making request to: $url');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'status': newStatus,
        }),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          final deviceIndex = devices.indexWhere((d) => d['_id'] == deviceId);
          if (deviceIndex != -1) {
            devices[deviceIndex]['status'] = newStatus;
          }
        });
        print('Status updated successfully');
      } else {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      print('Error updating status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update device status: $e')),
        );
      }
    }
  }

  Widget buildDevicesList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.brown),
      );
    }

    if (devices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No devices found',
          style: TextStyle(color: Colors.brown),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        final bool status = device['status'] ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          color: Colors.brown.shade300,
          child: ListTile(
            leading: Icon(
              Icons.power_settings_new,
              color: status ? Colors.green : Colors.grey,
            ),
            title: Text(
              device['deviceName'] ?? 'Unknown Device',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Power Device\n${status ? 'On' : 'Off'}',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Switch(
              value: status,
              onChanged: (value) => updateDeviceStatus(device['_id'], value),
              activeColor: Colors.green,
              inactiveTrackColor: Colors.red.shade200,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugs Panel'),
        backgroundColor: Colors.brown.shade50,
      ),
      body: RefreshIndicator(
        onRefresh: fetchDevices,
        child: Stack(
          children: [
            Image.asset(
              'assets/bg.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Devices',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildDevicesList(),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.brown,
                      child: ListTile(
                        title: const Text(
                          'Power Consumption',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          '120W',
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: const Icon(
                          Icons.show_chart,
                          color: Colors.white,
                        ),
                        onTap: () {
                          // Navigate to detailed power consumption view
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      color: Colors.brown,
                      child: ListTile(
                        title: const Text(
                          'Schedule',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          '2 active schedules',
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: const Icon(
                          Icons.schedule,
                          color: Colors.white,
                        ),
                        onTap: () {
                          // Navigate to schedule management
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}