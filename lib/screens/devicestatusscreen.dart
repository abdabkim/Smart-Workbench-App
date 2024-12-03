import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_workbench_app/screens/controlpanelscreen.dart';
import 'package:smart_workbench_app/screens/homescreen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceStatusScreen extends StatefulWidget {
  final String deviceType;
  final String category;
  final String area;

  const DeviceStatusScreen({
    super.key,
    required this.deviceType,
    required this.category,
    required this.area,
  });

  @override
  State<DeviceStatusScreen> createState() => _DeviceStatusScreenState();
}

class _DeviceStatusScreenState extends State<DeviceStatusScreen> {
  bool isDeviceOn = false;
  String? deviceId;
  List<dynamic> allDevices = [];
  bool isLoading = true;
  final String baseUrl = 'http://192.168.0.8:8000/device';
  String? authToken;

  @override
  void initState() {
    super.initState();
    _getAuthToken();
  }

  Future<void> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('token');
    print('Auth Token: $authToken');
    if (authToken != null) {
      _initializeDevice();
    } else {
      print('No auth token found');
      setState(() => isLoading = false);
    }
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };

  Future<void> _initializeDevice() async {
    if (authToken == null) {
      print('No auth token available');
      return;
    }

    setState(() => isLoading = true);
    try {
      await _loadAllDevices();
      if (!allDevices.any((device) =>
      device['deviceName'] == widget.deviceType &&
          device['area'] == widget.area)) {
        await _createNewDevice();
      }
    } catch (e) {
      print('Initialization error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadAllDevices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/retrieveall'),
        headers: _headers,
      );

      print('Load all devices response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          allDevices = List.from(data['devices'] ?? []);
          final currentDevice = allDevices.firstWhere(
                (device) =>
            device['deviceName'] == widget.deviceType &&
                device['area'] == widget.area,
            orElse: () => null,
          );

          if (currentDevice != null) {
            deviceId = currentDevice['_id'];
            isDeviceOn = currentDevice['status'] ?? false;
          }
        });
      } else {
        print('Failed to load devices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading devices: $e');
    }
  }

  Future<void> _createNewDevice() async {
    try {
      final deviceData = {
        'deviceName': widget.deviceType,
        'category': widget.category,
        'area': widget.area,
        'status': false,
      };

      print('Creating new device: $deviceData');

      final response = await http.post(
        Uri.parse('$baseUrl/new'),
        headers: _headers,
        body: json.encode(deviceData),
      );

      print('Create device response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        setState(() {
          deviceId = data['deviceID'];
          isDeviceOn = false;
        });
        await _loadAllDevices();
      } else {
        print('Failed to create device: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating device: $e');
    }
  }

  Future<void> _updateDeviceStatus(String id, bool newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update/$id'),
        headers: _headers,
        body: json.encode({'status': newStatus}),
      );

      print('Update status response: ${response.statusCode}');

      if (response.statusCode == 200) {
        setState(() {
          final deviceIndex = allDevices.indexWhere((d) => d['_id'] == id);
          if (deviceIndex != -1) {
            allDevices[deviceIndex]['status'] = newStatus;
            if (id == deviceId) isDeviceOn = newStatus;
          }
        });
      }
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  Widget _buildStatusCard(Map<String, dynamic> device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.brown.shade200.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.brown.shade300,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.power_settings_new,
                      color: Colors.brown.shade900,
                    ),
                  ),
                  Switch(
                    value: device['status'] ?? false,
                    onChanged: (value) => _updateDeviceStatus(device['_id'], value),
                    activeColor: Colors.brown.shade700,
                    activeTrackColor: Colors.brown.shade300,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device['deviceName'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device['area'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (device['status'] ?? false) ? 'On' : 'Off',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: (device['status'] ?? false) ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.brown.shade50,
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.brown,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(
        title: const Text('Device Status'),
        backgroundColor: Colors.brown.shade50,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown.shade50,
              Colors.brown.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Devices (${allDevices.length})',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.brown.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: allDevices.isEmpty
                      ? Center(
                    child: Text(
                      'No devices added yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown.shade400,
                      ),
                    ),
                  )
                      : ListView.builder(
                    itemCount: allDevices.length,
                    itemBuilder: (context, index) {
                      return _buildStatusCard(allDevices[index]);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ControlPanelScreen(
                            deviceType: widget.deviceType,
                            category: widget.category,
                            area: widget.area,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Control Panel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Home'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}