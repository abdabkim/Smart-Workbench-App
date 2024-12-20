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
  final String baseUrl = 'http://192.168.0.11:8000/device';
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

      final response = await http.post(
        Uri.parse('$baseUrl/new'),
        headers: _headers,
        body: json.encode(deviceData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        setState(() {
          deviceId = data['deviceID'];
          isDeviceOn = false;
        });
        await _loadAllDevices();
      }
    } catch (e) {
      print('Error creating device: $e');
    }
  }

  Future<void> triggerIFTTT(bool newStatus) async {
    final url = newStatus
        ? 'https://maker.ifttt.com/trigger/turn_on_devices/with/key/2ZySHZZprglWIony9x0DF'
        : 'https://maker.ifttt.com/trigger/turn_off_device/with/key/2ZySHZZprglWIony9x0DF';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to trigger IFTTT');
      }
    } catch (e) {
      print('Error triggering IFTTT: $e');
    }
  }

  Future<void> _updateDeviceStatus(String id, bool newStatus) async {
    try {
      await triggerIFTTT(newStatus);

      final response = await http.put(
        Uri.parse('$baseUrl/update/$id'),
        headers: _headers,
        body: json.encode({'status': newStatus.toString()}),
      );

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

  Future<void> _deleteDevice(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        setState(() {
          allDevices.removeWhere((device) => device['_id'] == id);
        });
      } else {
        print('Failed to delete device: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting device: $e');
    }
  }

  Widget _buildStatusCard(Map<String, dynamic> device) {
    final bool status = device['status'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.brown.shade400,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.brown.shade500,
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
                      color: status ? Colors.green : Colors.red,
                      size: 24,
                    ),
                  ),
                  Switch(
                    value: status,
                    onChanged: (value) => _updateDeviceStatus(device['_id'], value),
                    activeColor: Colors.green,
                    inactiveTrackColor: Colors.red.shade200,
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device['area'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status ? 'On' : 'Off',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: status ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Delete Device'),
                          content: const Text('Are you sure you want to delete this device?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                _deleteDevice(device['_id']);
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Delete Device',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Home'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}