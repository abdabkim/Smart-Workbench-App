import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
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
  List<AutomationSchedule> _schedules = [];
  bool isLoading = true;
  bool _initialized = false;
  String? authToken;
  Timer? _deviceSyncTimer;
  Timer? _scheduleSyncTimer;

  final Map<String, double> devicePowerRatings = {
    'Circular Saw': 1500.0,
    'Power Device': 1200.0,
    'Smart Light': 60.0,
    'Smart Switch': 800.0,
    'Smart Plug': 500.0,
    'Default': 100.0,
  };

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _getAuthTokenAndFetchDevices();
      await _loadSchedules();

      // Set up periodic device status sync (every 5 seconds)
      _deviceSyncTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _syncDeviceStatus(),
      );

      // Set up periodic schedule check (every minute)
      _scheduleSyncTimer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => _syncScheduleWithDeviceStatus(),
      );

      if (mounted) {
        setState(() {
          _initialized = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Initialization error: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _deviceSyncTimer?.cancel();
    _scheduleSyncTimer?.cancel();
    super.dispose();
  }

  Future<void> _syncDeviceStatus() async {
    if (!mounted || authToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/retrieveall'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final responseData = json.decode(response.body);
        final newDevices = responseData['devices'] ?? [];

        // Only update state if device status has actually changed
        if (_hasDeviceStatusChanged(devices, newDevices)) {
          setState(() {
            devices = newDevices;
          });
        }
      }
    } catch (e) {
      print('Error syncing device status: $e');
    }
  }

  bool _hasDeviceStatusChanged(List<dynamic> oldDevices, List<dynamic> newDevices) {
    if (oldDevices.length != newDevices.length) return true;

    for (int i = 0; i < oldDevices.length; i++) {
      if (oldDevices[i]['status'] != newDevices[i]['status']) {
        return true;
      }
    }
    return false;
  }

  Future<void> _syncScheduleWithDeviceStatus() async {
    if (!mounted) return;

    final now = DateTime.now();
    bool scheduleExecuted = false;

    for (var schedule in _schedules) {
      if (schedule.days.contains(DayOfWeek.values[now.weekday - 1])) {
        if (now.hour == schedule.timeOfDay.hour &&
            now.minute == schedule.timeOfDay.minute) {
          final deviceName = schedule.device.split(' (')[0];
          final device = devices.firstWhere(
            (d) => d['deviceName'] == deviceName,
            orElse: () => null,
          );

          if (device != null && device['status'] != schedule.action) {
            scheduleExecuted = true;
            await updateDeviceStatus(device['_id'], schedule.action);
          }
        }
      }
    }

    if (scheduleExecuted) {
      await _syncDeviceStatus();
    }
  }

  Future<void> _getAuthTokenAndFetchDevices() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('token');
    if (authToken != null) {
      await fetchDevices();
    }
  }

  Future<void> _loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final schedulesJson = prefs.getStringList('schedules') ?? [];
    if (mounted) {
      setState(() {
        _schedules = schedulesJson
            .map((json) => AutomationSchedule.fromJson(jsonDecode(json)))
            .toList();
      });
    }
  }

  Future<void> fetchDevices() async {
    if (authToken == null || !mounted) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/retrieveall'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final responseData = json.decode(response.body);
        setState(() {
          devices = responseData['devices'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching devices: $e');
      if (mounted) {
        setState(() => isLoading = false);
        _showError('Failed to load devices');
      }
    }
  }

  Future<void> updateDeviceStatus(String deviceId, bool newStatus) async {
    if (!mounted || authToken == null) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update/$deviceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'status': newStatus.toString()}),
      );

      if (response.statusCode == 200) {
        await _syncDeviceStatus();
        await triggerIFTTT(newStatus);
      }
    } catch (e) {
      print('Error updating status: $e');
      _showError('Failed to update device status');
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
      _showError('Failed to trigger IFTTT');
    }
  }

  Future<void> _deleteDevice(String id) async {
    if (!mounted || authToken == null) return;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200 && mounted) {
        await _syncDeviceStatus();
      }
    } catch (e) {
      print('Error deleting device: $e');
      _showError('Failed to delete device');
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

  String formatPowerConsumption(double power) {
    if (power >= 1000) {
      return '${(power / 1000).toStringAsFixed(2)}kW';
    }
    return '${power.toStringAsFixed(1)}W';
  }

  Widget buildPowerConsumptionCard() {
    if (!_initialized) {
      return const Card(
        color: Colors.brown,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    final activeDevices = devices.where((device) => device['status'] == true).toList();
    double totalPower = 0.0;

    for (var device in activeDevices) {
      String deviceName = device['deviceName'] ?? 'Default';
      totalPower += devicePowerRatings[deviceName] ?? devicePowerRatings['Default']!;
    }

    return Card(
      color: Colors.brown,
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Power Consumption',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.power,
                  color: activeDevices.isNotEmpty ? Colors.green : Colors.white70,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Active Devices: ${activeDevices.length}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            if (activeDevices.isNotEmpty) ...[
              const Divider(color: Colors.white24),
              ...activeDevices.map((device) {
                String deviceName = device['deviceName'] ?? 'Default';
                double power = devicePowerRatings[deviceName] ?? devicePowerRatings['Default']!;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        deviceName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        formatPowerConsumption(power),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ] else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No active devices',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            const Divider(color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Consumption:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formatPowerConsumption(totalPower),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        bool status = device['status'] ?? false;

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
                          widget.deviceType,
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
                              content: const Text(
                                  'Are you sure you want to delete this device?'
                              ),
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
      },
    );
  }

  Widget buildScheduleCard() {
    return SizedBox(
      height: 100,
      child: Card(
        color: Colors.brown,
        margin: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: const Text(
            'Schedule',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          subtitle: Text(
            _buildScheduleText(),
            style: const TextStyle(color: Colors.white70),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.schedule, color: Colors.white),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AutomationScreen()),
          ).then((_) async {
            await _loadSchedules();
            await _syncScheduleWithDeviceStatus();
          }),
        ),
      ),
    );
  }

  String _buildScheduleText() {
    if (!_initialized) return 'Loading...';

    final deviceSchedules = _schedules.where((schedule) =>
        devices.any((device) =>
        "${device['deviceName']} (${device['area']})" == schedule.device)).toList();

    if (deviceSchedules.isEmpty) {
      return 'No active schedules';
    }

    return '${deviceSchedules.length} active schedule(s)';
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
                    buildPowerConsumptionCard(),
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