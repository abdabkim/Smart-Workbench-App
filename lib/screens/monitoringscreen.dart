import 'package:flutter/material.dart';
import 'package:smart_workbench_app/widget/monitoringcard.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({Key? key}) : super(key: key);

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  Map<String, dynamic> sensorData = {
    'temperature': '22°C',
    'humidity': '45%',
    'powerConsumption': '120W',
    'motion': 'No motion detected'
  };
  List<Map<String, dynamic>> historicalData = [];
  List<Map<String, dynamic>> alerts = [];
  Timer? _timer;
  final String baseUrl = 'http://192.168.0.8:8000';

  // Sensor status tracking
  bool _isDataStale = false;
  DateTime? _lastUpdateTime;
  int _consecutiveFailures = 0;
  bool _isSensorActive = true;

  final Map<String, Map<String, double>> thresholds = {
    'temperature': {'min': 18, 'max': 30},
    'humidity': {'min': 30, 'max': 60},
    'powerConsumption': {'min': 0, 'max': 200},
  };

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _initializeHistoricalData();
    fetchSensorData();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchSensorData();
      _updateHistoricalData();
      _checkAlerts();
    });
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  void _initializeHistoricalData() {
    final now = DateTime.now();
    setState(() {
      historicalData = List.generate(20, (index) {
        return {
          'timestamp': now.subtract(Duration(minutes: index)).toString(),
          'temperature': '22°C',
          'humidity': '45%',
          'powerConsumption': '120W',
        };
      });
    });
  }

  void _updateHistoricalData() {
    if (mounted) {
      setState(() {
        historicalData.add({
          'timestamp': DateTime.now().toString(),
          'temperature': sensorData['temperature'],
          'humidity': sensorData['humidity'],
          'powerConsumption': sensorData['powerConsumption'],
        });

        if (historicalData.length > 20) {
          historicalData.removeAt(0);
        }
      });
    }
  }

  void _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'sensor_alerts',
      'Sensor Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      details,
    );
  }

  Future<void> fetchSensorData() async {
    try {
      final Uri uri = Uri.parse('$baseUrl/device/devicestatus');

      final queryParams = {
        'detailed': 'true',
        'includeMetadata': 'true',
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      final urlWithParams = uri.replace(queryParameters: queryParams);

      final response = await http.get(urlWithParams).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _handleSensorFailure('Request timed out');
          throw TimeoutException('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (mounted) {
          setState(() {
            sensorData = decodedData['currentReading'] ?? sensorData;
            _isDataStale = false;
            _lastUpdateTime = DateTime.now();
            _consecutiveFailures = 0;
            _isSensorActive = true;

            _updateSensorHealth(decodedData['metadata'] ?? {});
          });
        }

        _processImmediateAlerts(decodedData['alerts'] ?? []);

      } else {
        _handleSensorFailure('Invalid response: ${response.statusCode}');
      }
    } catch (e) {
      _handleSensorFailure(e.toString());
    }
  }

  void _handleSensorFailure(String error) {
    if (mounted) {
      setState(() {
        _consecutiveFailures++;
        _isDataStale = true;

        if (_consecutiveFailures >= 3) {
          _isSensorActive = false;
          _addAlert(
              'Sensor Status Alert',
              'Sensor connection lost. Consecutive failures: $_consecutiveFailures'
          );
        }

        sensorData = Map.from(sensorData)..update('motion', (value) => 'Sensor Error');
      });
    }
    print('Sensor error: $error');
  }

  void _updateSensorHealth(Map<String, dynamic> metadata) {
    final batteryLevel = metadata['batteryLevel'];
    if (batteryLevel != null && batteryLevel < 20) {
      _addAlert(
          'Sensor Battery Alert',
          'Low battery level: $batteryLevel%'
      );
    }

    final signalStrength = metadata['signalStrength'];
    if (signalStrength != null && signalStrength < 50) {
      _addAlert(
          'Sensor Connection Alert',
          'Weak signal strength: $signalStrength%'
      );
    }
  }

  void _processImmediateAlerts(List<dynamic> immediateAlerts) {
    for (var alert in immediateAlerts) {
      if (alert is Map<String, dynamic>) {
        _addAlert(
            alert['type'] ?? 'Sensor Alert',
            alert['message'] ?? 'Unknown alert'
        );
      }
    }
  }

  void _checkAlerts() {
    final temp = extractNumericValue(sensorData['temperature']);
    final humidity = extractNumericValue(sensorData['humidity']);
    final power = extractNumericValue(sensorData['powerConsumption']);

    if (temp > thresholds['temperature']!['max']!) {
      _addAlert('Temperature Alert', 'High temperature detected: ${sensorData['temperature']}');
    } else if (temp < thresholds['temperature']!['min']!) {
      _addAlert('Temperature Alert', 'Low temperature detected: ${sensorData['temperature']}');
    }

    if (humidity > thresholds['humidity']!['max']!) {
      _addAlert('Humidity Alert', 'High humidity detected: ${sensorData['humidity']}');
    } else if (humidity < thresholds['humidity']!['min']!) {
      _addAlert('Humidity Alert', 'Low humidity detected: ${sensorData['humidity']}');
    }

    if (power > thresholds['powerConsumption']!['max']!) {
      _addAlert('Power Alert', 'High power consumption: ${sensorData['powerConsumption']}');
    }

    if (sensorData['motion'] != 'No motion detected') {
      _addAlert('Motion Alert', 'Motion detected in the workspace');
    }
  }

  void _addAlert(String title, String message) {
    setState(() {
      alerts.insert(0, {
        'title': title,
        'message': message,
        'timestamp': DateTime.now(),
      });

      if (alerts.length > 5) {
        alerts.removeLast();
      }
    });

    _showNotification(title, message);
  }

  Widget _buildSensorStatusIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _isSensorActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSensorActive ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isSensorActive ? Colors.green : Colors.red,
            ),
          ),
          SizedBox(width: 4),
          Text(
            _isSensorActive
                ? 'Sensors Active'
                : 'Sensor Error',
            style: TextStyle(
              color: _isSensorActive ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
          if (_isDataStale) ...[
            SizedBox(width: 4),
            Icon(
              Icons.warning,
              size: 14,
              color: Colors.orange,
            ),
          ],
        ],
      ),
    );
  }

  double extractNumericValue(String value) {
    return double.parse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
  }

  List<FlSpot> getChartData(String metric) {
    return historicalData.asMap().entries.map((entry) {
      final value = extractNumericValue(entry.value[metric]);
      return FlSpot(entry.key.toDouble(), value);
    }).toList();
  }

  IconData _getAlertIcon(String alertType) {
    switch (alertType) {
      case 'Temperature Alert':
        return Icons.thermostat;
      case 'Humidity Alert':
        return Icons.water_drop;
      case 'Power Alert':
        return Icons.electric_bolt;
      case 'Motion Alert':
        return Icons.motion_photos_on;
      default:
        return Icons.warning;
    }
  }

  Color _getAlertColor(String alertType) {
    switch (alertType) {
      case 'Temperature Alert':
        return Colors.red;
      case 'Humidity Alert':
        return Colors.blue;
      case 'Power Alert':
        return Colors.orange;
      case 'Motion Alert':
        return Colors.purple;
      default:
        return Colors.yellow;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown.shade50.withOpacity(0.8),
              Colors.brown.shade100.withOpacity(0.8),
            ],
          ),
        ),
        child: DefaultTabController(
            length: 3,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monitoring',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Theme(
                    data: ThemeData(
                      tabBarTheme: TabBarTheme(
                        labelStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    child: TabBar(
                      tabs: [
                        Tab(text: 'Current'),
                        Tab(text: 'History'),
                        Tab(text: 'Alerts'),
                      ],
                      labelColor: Colors.brown,
                      unselectedLabelColor: Colors.brown.shade300,
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Current Readings Tab
                        ListView(
                          children: [
                            MonitoringCard(
                              title: 'Temperature',
                              value: sensorData['temperature'] ?? '22°C',
                              icon: Icons.thermostat,
                            ),
                            MonitoringCard(
                              title: 'Humidity',
                              value: sensorData['humidity'] ?? '45%',
                              icon: Icons.water_drop,
                            ),
                            MonitoringCard(
                              title: 'Power Usage',
                              value: sensorData['powerConsumption'] ?? '120W',
                              icon: Icons.electric_bolt,
                            ),
                            MonitoringCard(
                              title: 'Motion',
                              value: sensorData['motion'] ?? 'No motion detected',
                              icon: Icons.motion_photos_on,
                            ),
                          ],
                        ),
                        // Historical Data Tab
                        Container(
                          color: Colors.white.withOpacity(0.8),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  height: 300,
                                  padding: EdgeInsets.all(16),
                                  child: LineChart(
                                    LineChartData(
                                      gridData: FlGridData(show: true),
                                      titlesData: FlTitlesData(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              return Text(value.toInt().toString());
                                            },
                                            reservedSize: 40,
                                          ),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: true),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: getChartData('temperature'),
                                          isCurved: true,
                                          color: Colors.red,
                                          barWidth: 3,
                                          dotData: FlDotData(show: true),
                                        ),
                                        LineChartBarData(
                                          spots: getChartData('humidity'),
                                          isCurved: true,
                                          color: Colors.blue,
                                          barWidth: 3,
                                          dotData: FlDotData(show: true),
                                        ),
                                        LineChartBarData(
                                          spots: getChartData('powerConsumption'),
                                          isCurved: true,
                                          color: Colors.green,
                                          barWidth: 3,
                                          dotData: FlDotData(show: true),
                                        ),
                                      ],
                                      minX: 0,
                                      maxX: 19,
                                      minY: 0,
                                      maxY: 150,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildLegendItem('Temperature (°C)', Colors.red),
                                      _buildLegendItem('Humidity (%)', Colors.blue),
                                      _buildLegendItem('Power (W)', Colors.green),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Alerts Tab
                        Container(
                          color: Colors.white.withOpacity(0.8),
                          child: ListView.builder(
                            itemCount: alerts.length,
                            padding: EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final alert = alerts[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Icon(
                                    _getAlertIcon(alert['title']),
                                    color: _getAlertColor(alert['title']),
                                  ),
                                  title: Text(alert['title']),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(alert['message']),
                                      Text(
                                        _formatTimestamp(alert['timestamp']),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}