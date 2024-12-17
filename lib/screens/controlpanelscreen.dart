import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_workbench_app/models/automation_schedule.dart';
import 'package:smart_workbench_app/screens/automationscreen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';

class PowerUsageData {
  final DateTime timestamp;
  final double power;
  PowerUsageData(this.timestamp, this.power);
}

class PowerUsagePattern {
  final String deviceId;
  final List<TimeOfDay> commonUsageTimes;
  final double averageDuration;
  final double peakPower;
  PowerUsagePattern(this.deviceId, this.commonUsageTimes, this.averageDuration, this.peakPower);
}

class PowerScheduleRule {
  final String deviceId;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<DayOfWeek> days;
  final bool shouldTurnOn;
  PowerScheduleRule(this.deviceId, this.startTime, this.endTime, this.days, this.shouldTurnOn);
}

class EnergyRecommendation {
  final String title;
  final String description;
  final double potentialSavings;
  EnergyRecommendation(this.title, this.description, this.potentialSavings);
}

class PowerCalculator {
  static const String prefsKey = 'device_power_ratings';

  static final Map<String, (double, double)> categoryPowerRanges = {
    'Power Tools': (500.0, 2000.0),
    'Hand Tools': (50.0, 200.0),
    'Lighting': (20.0, 100.0),
    'Safety': (5.0, 50.0),
    'Storage': (0.0, 10.0),
    'Workbench': (100.0, 500.0),
    'Default': (50.0, 300.0)
  };

  static final Map<String, double> typePowerFactors = {
    'Cutting': 1.5,
    'Drilling': 1.2,
    'Sanding': 1.0,
    'Measuring': 0.3,
    'Safety': 0.2,
    'Storage': 0.1,
    'Default': 1.0
  };

  static double calculatePower(String deviceName, String deviceType, String category) {
    var (minPower, maxPower) = categoryPowerRanges[category] ?? categoryPowerRanges['Default']!;
    double typeFactor = typePowerFactors[deviceType] ?? typePowerFactors['Default']!;

    double basePower = minPower + (maxPower - minPower) * 0.6;
    double randomFactor = 0.9 + (Random().nextDouble() * 0.2);
    double calculatedPower = basePower * typeFactor * randomFactor;

    return (calculatedPower / 10).round() * 10;
  }
}

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
  static const String powerRatingsKey = 'power_ratings';
  final String baseUrl = 'http://192.168.0.11:8000/device';
  List<dynamic> devices = [];
  List<AutomationSchedule> _schedules = [];
  Map<String, List<PowerUsageData>> deviceUsageHistory = {};
  Map<String, PowerUsagePattern> deviceUsagePatterns = {};
  List<PowerScheduleRule> automatedRules = [];
  List<EnergyRecommendation> energyRecommendations = [];
  Map<String, double> devicePowerRatings = {};
  bool showAnalytics = false;
  bool isLoading = true;
  bool _initialized = false;
  String? authToken;
  Timer? _deviceSyncTimer;
  Timer? _scheduleSyncTimer;
  Timer? _powerMonitoringTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _deviceSyncTimer?.cancel();
    _scheduleSyncTimer?.cancel();
    _powerMonitoringTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await _getAuthTokenAndFetchDevices();
      await _loadSchedules();
      await _loadPowerRatings();

      for (var device in devices) {
        await updateDevicePower(
            device['deviceName'],
            device['deviceType'] ?? widget.deviceType,
            device['category'] ?? widget.category
        );
      }

      _deviceSyncTimer = Timer.periodic(
        const Duration(seconds: 5),
            (_) => _syncDeviceStatus(),
      );

      _scheduleSyncTimer = Timer.periodic(
        const Duration(minutes: 1),
            (_) => _syncScheduleWithDeviceStatus(),
      );

      _startPowerMonitoring();

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

  Future<void> _loadPowerRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final storedRatings = prefs.getString(powerRatingsKey);
    if (storedRatings != null) {
      setState(() {
        devicePowerRatings = Map<String, double>.from(json.decode(storedRatings));
      });
    }
  }

  Future<void> _savePowerRatings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(powerRatingsKey, json.encode(devicePowerRatings));
  }

  Future<void> updateDevicePower(String deviceName, String deviceType, String category) async {
    if (!devicePowerRatings.containsKey(deviceName)) {
      devicePowerRatings[deviceName] = PowerCalculator.calculatePower(
          deviceName,
          deviceType,
          category
      );
      await _savePowerRatings();
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

  void _startPowerMonitoring() {
    _powerMonitoringTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _recordPowerUsage();
      _analyzeUsagePatterns();
      _generateRecommendations();
    });
  }
  void _recordPowerUsage() {
    final now = DateTime.now();

    if (deviceUsageHistory.isEmpty) {
      for (var hour = 0; hour < 24; hour++) {
        for (var device in devices) {
          String deviceName = device['deviceName'];
          bool isWorkHour = hour >= 8 && hour <= 17;
          bool isPeakHour = hour >= 13 && hour <= 16;

          double basePower = devicePowerRatings[deviceName] ?? 100.0;

          double powerFactor = 0.0;
          if (isWorkHour) {
            powerFactor = isPeakHour ? 1.0 : 0.8;
          } else if (hour >= 6 && hour <= 19) {
            powerFactor = 0.5;
          } else {
            powerFactor = 0.1;
          }

          double randomFactor = 0.8 + (Random().nextDouble() * 0.4);
          double power = device['status'] == true ? basePower * powerFactor * randomFactor : 0.0;

          deviceUsageHistory.putIfAbsent(deviceName, () => []);
          deviceUsageHistory[deviceName]!.add(PowerUsageData(
              now.subtract(Duration(hours: 24 - hour)),
              power
          ));
        }
      }
    }

    for (var device in devices) {
      if (device['status'] == true) {
        String deviceName = device['deviceName'];
        double basePower = devicePowerRatings[deviceName] ?? 100.0;

        double randomFactor = 0.9 + (Random().nextDouble() * 0.2);
        double power = basePower * randomFactor;

        deviceUsageHistory.putIfAbsent(deviceName, () => []);
        deviceUsageHistory[deviceName]!.add(PowerUsageData(now, power));

        if (deviceUsageHistory[deviceName]!.length > 96) {
          deviceUsageHistory[deviceName]!.removeAt(0);
        }
      }
    }

    if (mounted) setState(() {});
  }

  void _analyzeUsagePatterns() {
    for (var device in devices) {
      final String deviceId = device['_id'];
      final usageData = deviceUsageHistory[device['deviceName']] ?? [];

      if (usageData.length >= 24) {
        var hourlyUsage = groupBy(usageData,
                (PowerUsageData data) => data.timestamp.hour);

        List<TimeOfDay> commonTimes = [];
        for (var entry in hourlyUsage.entries) {
          if (entry.value.where((d) => d.power > 0).length / entry.value.length > 0.5) {
            commonTimes.add(TimeOfDay(hour: entry.key, minute: 0));
          }
        }

        double avgDuration = usageData
            .where((d) => d.power > 0)
            .length / 24 * 24;

        double peakPower = usageData
            .map((d) => d.power)
            .reduce(max);

        deviceUsagePatterns[deviceId] = PowerUsagePattern(
            deviceId,
            commonTimes,
            avgDuration,
            peakPower
        );
      }
    }
  }

  void _generateRecommendations() {
    energyRecommendations.clear();

    final activeDevices = devices.where((d) => d['status'] == true).toList();
    double totalCurrentPower = 0.0;

    for (var device in activeDevices) {
      String deviceName = device['deviceName'];
      double power = devicePowerRatings[deviceName] ?? 100.0;
      totalCurrentPower += power;

      if (power > 1000.0) {
        energyRecommendations.add(EnergyRecommendation(
            'High Power Device Alert',
            '$deviceName (${power.toStringAsFixed(1)}W) is active. Consider using during off-peak hours.',
            15.0
        ));
      }
    }

    if (totalCurrentPower > 2500.0) {
      energyRecommendations.add(EnergyRecommendation(
          'Peak Load Warning',
          'Total power draw: ${totalCurrentPower.toStringAsFixed(1)}W. Consider staggering device usage.',
          25.0
      ));
    }

    for (var pattern in deviceUsagePatterns.values) {
      var device = devices.firstWhere((d) => d['_id'] == pattern.deviceId);
      String deviceName = device['deviceName'];

      if (pattern.peakPower > 1000 && pattern.averageDuration > 4) {
        energyRecommendations.add(EnergyRecommendation(
            'Usage Pattern Alert',
            '$deviceName has been running at high power for extended periods.',
            20.0
        ));
      }

      if (pattern.commonUsageTimes.any((time) => time.hour >= 13 && time.hour <= 16)) {
        energyRecommendations.add(EnergyRecommendation(
            'Peak Hour Usage',
            'Consider using $deviceName outside peak hours (1 PM - 4 PM).',
            30.0
        ));
      }
    }

    if (mounted) setState(() {});
  }

  Future<void> _syncScheduleWithDeviceStatus() async {
    if (!mounted) return;

    final now = DateTime.now();
    TimeOfDay currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
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
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPowerHeader(activeDevices),
                _buildActiveDevicesList(activeDevices),
                _buildTotalConsumption(totalPower),
              ],
            ),
          ),
          if (showAnalytics) ...[
            const Divider(color: Colors.white24),
            _buildAnalyticsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildPowerHeader(List<dynamic> activeDevices) {
    return Row(
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
        Row(
          children: [
            IconButton(
              icon: Icon(
                showAnalytics ? Icons.hide_source : Icons.analytics,
                color: Colors.white,
              ),
              onPressed: () => setState(() => showAnalytics = !showAnalytics),
            ),
            Icon(
              Icons.power,
              color: activeDevices.isNotEmpty ? Colors.green : Colors.white70,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveDevicesList(List<dynamic> activeDevices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Devices: ${activeDevices.length}',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        if (activeDevices.isNotEmpty) ...[
          const Divider(color: Colors.white24),
          ...activeDevices.map((device) {
            String deviceName = device['deviceName'] ?? 'Default';
            double power = devicePowerRatings[deviceName] ?? 100.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(deviceName, style: const TextStyle(color: Colors.white)),
                  Text(formatPowerConsumption(power),
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            );
          }).toList(),
        ] else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No active devices',
                style: TextStyle(color: Colors.white70)),
          ),
      ],
    );
  }

  Widget _buildTotalConsumption(double totalPower) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Total Consumption:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(formatPowerConsumption(totalPower),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAnalyticsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Usage Analytics',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(_buildUsageChart()),
          ),
          const SizedBox(height: 16),
          const Text('Energy Saving Recommendations',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...energyRecommendations.map((rec) => ListTile(
            title: Text(rec.title, style: const TextStyle(color: Colors.white)),
            subtitle: Text(rec.description, style: const TextStyle(color: Colors.white70)),
            trailing: Text('~${rec.potentialSavings.toStringAsFixed(1)}% savings',
                style: const TextStyle(color: Colors.green)),
          )).toList(),
        ],
      ),
    );
  }

  LineChartData _buildUsageChart() {
    List<FlSpot> spots = [];
    final now = DateTime.now();

    for (int hour = 0; hour < 24; hour++) {
      DateTime timePoint = now.subtract(Duration(hours: 24 - hour));
      double totalPower = 0.0;

      for (var deviceData in deviceUsageHistory.values) {
        var hourData = deviceData.where((data) =>
        data.timestamp.hour == timePoint.hour);
        if (hourData.isNotEmpty) {
          totalPower += hourData.map((d) => d.power).reduce((a, b) => a + b) / hourData.length;
        }
      }

      spots.add(FlSpot(hour.toDouble(), totalPower));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 500,
        verticalInterval: 4,
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 1),
        getDrawingVerticalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 500,
          ),
        ),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 4,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white24),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.white,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      ],
      minX: 0,
      maxX: 23,
      minY: 0,
      maxY: _calculateMaxY(),
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
          child: Text('No devices found',
              style: TextStyle(color: Colors.brown, fontSize: 16, fontWeight: FontWeight.bold)),
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
            border: Border.all(color: Colors.brown.shade500, width: 1),
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
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
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
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Delete Device', style: TextStyle(color: Colors.red)),
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
          title: const Text('Schedule',
              style: TextStyle(color: Colors.white, fontSize: 16)),
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

  double _calculateMaxY() {
    double maxPower = 0.0;
    for (var deviceData in deviceUsageHistory.values) {
      for (var data in deviceData) {
        if (data.power > maxPower) maxPower = data.power;
      }
    }
    return ((maxPower + 500) / 500).ceil() * 500;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Panel',
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
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
                    const Text('All Devices',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown)),
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