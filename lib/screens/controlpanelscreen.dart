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
  final String baseUrl = 'http://192.168.0.10:8000/device';
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
        _syncScheduleWithDeviceStatus(); // Sync after loading devices
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

            // Check if there's an active schedule for this device
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
                  onChanged: (bool value) {
                    updateDeviceStatus(device['_id'], value);
                  },
                  activeColor: Colors.green,
                  inactiveTrackColor: Colors.red.shade200,
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