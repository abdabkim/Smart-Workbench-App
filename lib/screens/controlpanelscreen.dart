import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_workbench_app/models/automation_schedule.dart';
import 'package:smart_workbench_app/screens/automationscreen.dart';

class ControlPanelScreen extends StatefulWidget {
  final String deviceType;
  final String category;
  final String area;

  const ControlPanelScreen({
    super.key,
    required this.deviceType,
    required this.category,
    required this.area,
  });

  @override
  State<ControlPanelScreen> createState() => _ControlPanelScreenState();
}

class _ControlPanelScreenState extends State<ControlPanelScreen> {
  final String baseUrl = 'http://192.168.0.8:8000/device';
  List<dynamic> devices = [];
  bool isLoading = true;
  String? authToken;

  @override
  void initState() {
    super.initState();
    _getAuthTokenAndFetchDevices();
    _syncScheduleWithDeviceStatus();
  }

  Future<void> _syncScheduleWithDeviceStatus() async {
    final schedules = await _loadSchedules();
    final now = DateTime.now();

    for (var schedule in schedules) {
      if (schedule.days.contains(DayOfWeek.values[now.weekday - 1])) {
        if (now.hour == schedule.timeOfDay.hour &&
            now.minute == schedule.timeOfDay.minute) {
          final deviceName = schedule.device.split(' (')[0];
          final device = devices.firstWhere(
                (d) => d['deviceName'] == deviceName,
            orElse: () => null,
          );
          if (device != null) {
            setState(() {
              device['status'] = schedule.action;
            });
            await updateDeviceStatus(device['_id'], schedule.action);
          }
        }
      }
    }
  }

  Future<void> _getAuthTokenAndFetchDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        authToken = prefs.getString('token');
      });
      await fetchDevices();
    } catch (e) {
      print('Error getting auth token: $e');
      _showError('Failed to initialize: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _deleteDevice(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      print('Delete device response: ${response.statusCode}');

      if (response.statusCode == 200) {
        setState(() {
          devices.removeWhere((device) => device['_id'] == id);
        });
      } else {
        throw Exception('Failed to delete device');
      }
    } catch (e) {
      print('Error deleting device: $e');
      _showError('Failed to delete device: $e');
    }
  }

  Future<void> triggerIFTTT(bool newStatus) async {
    final url = newStatus
        ? 'https://maker.ifttt.com/trigger/turn_on_devices/with/key/2ZySHZZprglWIony9x0DF'
        : 'https://maker.ifttt.com/trigger/turn_off_device/with/key/2ZySHZZprglWIony9x0DF';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print('IFTTT Triggered successfully!');
      } else {
        throw Exception('Failed to trigger IFTTT');
      }
    } catch (e) {
      print('Error triggering IFTTT: $e');
      _showError('Failed to trigger IFTTT: $e');
    }
  }

  Future<void> fetchDevices() async {
    if (authToken == null) {
      _showError('No authentication token available');
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/retrieveall'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          devices = responseData['devices'] ?? [];
          isLoading = false;
        });
        _syncScheduleWithDeviceStatus();
      } else {
        throw Exception('Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error fetching devices: $e');
      if (mounted) {
        setState(() => isLoading = false);
        _showError('Failed to load devices: $e');
      }
    }
  }

  Future<void> updateDeviceStatus(String deviceId, bool newStatus) async {
    if (authToken == null) {
      _showError('No authentication token available');
      return;
    }

    try {
      await triggerIFTTT(newStatus);

      setState(() {
        final deviceIndex = devices.indexWhere((d) => d['_id'] == deviceId);
        if (deviceIndex != -1) {
          devices[deviceIndex]['status'] = newStatus;
        }
      });

      final response = await http.put(
        Uri.parse('$baseUrl/update/$deviceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'status': newStatus.toString(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode != 200) {
        setState(() {
          final deviceIndex = devices.indexWhere((d) => d['_id'] == deviceId);
          if (deviceIndex != -1) {
            devices[deviceIndex]['status'] = !newStatus;
          }
        });
        throw Exception('Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error updating status: $e');
      if (mounted) {
        _showError('Failed to update device status: $e');
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No devices found',
            style: TextStyle(
              color: Colors.brown,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return FutureBuilder<List<AutomationSchedule>>(
      future: _loadSchedules(),
      builder: (context, snapshot) {
        final schedules = snapshot.data ?? [];

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            bool status = device['status'] ?? false;

            final now = DateTime.now();
            final activeSchedule = schedules.isNotEmpty ? schedules.firstWhere(
                  (s) => s.device.startsWith(device['deviceName']) &&
                  s.days.contains(DayOfWeek.values[now.weekday - 1]) &&
                  now.hour == s.timeOfDay.hour &&
                  now.minute == s.timeOfDay.minute,
              orElse: () => schedules.first,
            ) : null;

            if (activeSchedule != null) {
              status = activeSchedule.action;
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
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
                            onChanged: (bool value) {
                              updateDeviceStatus(device['_id'], value);
                            },
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
                              'Power Device',
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
                                        Navigator.pop(context); // Only close dialog
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
          },
        );
      },
    );
  }



  Widget buildScheduleCard() {
    return Card(
      color: Colors.brown,
      child: FutureBuilder<List<AutomationSchedule>>(
        future: _loadSchedules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ListTile(
              title: Text('Schedule', style: TextStyle(color: Colors.white)),
              subtitle: Text('Loading...', style: TextStyle(color: Colors.white70)),
              trailing: Icon(Icons.schedule, color: Colors.white),
            );
          }

          final schedules = snapshot.data ?? [];
          final deviceSchedules = schedules.where((schedule) =>
              devices.any((device) =>
              "${device['deviceName']} (${device['area']})" == schedule.device
              )
          ).toList();

          return ListTile(
            title: const Text('Schedule', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              deviceSchedules.isEmpty
                  ? 'No active schedules'
                  : '${deviceSchedules.length} active schedule(s)\n' +
                  deviceSchedules.map((s) =>
                  '${s.device}: ${s.getFormattedTime()} ${s.action ? 'ON' : 'OFF'}'
                  ).join(', '),
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: const Icon(Icons.schedule, color: Colors.white),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AutomationScreen()),
            ).then((_) {
              setState(() {});
              _syncScheduleWithDeviceStatus();
            }),
          );
        },
      ),
    );
  }

  Future<List<AutomationSchedule>> _loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final schedulesJson = prefs.getStringList('schedules') ?? [];
    return schedulesJson.map((json) =>
        AutomationSchedule.fromJson(jsonDecode(json))
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Control Panel',
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                    buildScheduleCard(),
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